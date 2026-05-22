import 'dart:async';
import 'dart:io';

import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/models/chat_models.dart';
import 'package:fitness/services/chat_service.dart';
import 'package:fitness/services/chat_socket_service.dart';
import 'package:fitness/services/user_service.dart';
import 'package:fitness/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderUserId;
  final String text;
  final bool isMe;
  final String time;
  final DateTime? createdAt;
  final String messageType;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime? seenAt;
  final bool isPending;
  final bool isFailed;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.text,
    required this.isMe,
    required this.time,
    this.createdAt,
    this.messageType = 'TEXT',
    this.attachmentUrl,
    this.attachmentType,
    this.seenAt,
    this.isPending = false,
    this.isFailed = false,
  });

  factory ChatMessage.fromModel(
    ChatMessageModel model, {
    required String? currentUserId,
  }) {
    return ChatMessage(
      id: model.id,
      conversationId: model.conversationId,
      senderUserId: model.senderUserId,
      text: model.text,
      isMe: currentUserId != null && model.senderUserId == currentUserId,
      time: _formatMessageTime(model.createdAt),
      createdAt: model.createdAt,
      messageType: model.messageType,
      attachmentUrl: model.attachmentUrl,
      attachmentType: model.attachmentType,
      seenAt: model.seenAt,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderUserId,
    String? text,
    bool? isMe,
    String? time,
    DateTime? createdAt,
    String? messageType,
    String? attachmentUrl,
    String? attachmentType,
    DateTime? seenAt,
    bool? isPending,
    bool? isFailed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderUserId: senderUserId ?? this.senderUserId,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      seenAt: seenAt ?? this.seenAt,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

class ChatContact {
  final String id;
  final String? memberUserId;
  final String? trainerUserId;
  final String? participantUserId;
  final String name;
  final String lastMessage;
  final String? avatarUrl;
  final int unreadCount;
  final DateTime? updatedAt;
  final bool isParticipantActive;

  const ChatContact({
    required this.id,
    this.memberUserId,
    this.trainerUserId,
    this.participantUserId,
    required this.name,
    required this.lastMessage,
    this.avatarUrl,
    this.unreadCount = 0,
    this.updatedAt,
    this.isParticipantActive = false,
  });

  factory ChatContact.fromModel(
    ChatConversationModel model, {
    required String? currentUserId,
  }) {
    final isTrainer = currentUserId != null &&
        currentUserId.isNotEmpty &&
        currentUserId == model.trainerUserId;
    final participant = isTrainer ? model.member : model.trainer;
    final participantUserId =
        isTrainer ? model.memberUserId : model.trainerUserId;
    final participantStatus =
        isTrainer ? model.memberStatus : model.trainerStatus;

    return ChatContact(
      id: model.id,
      memberUserId: model.memberUserId,
      trainerUserId: model.trainerUserId,
      participantUserId: participantUserId,
      name: participant?.name ?? (isTrainer ? 'Member' : 'Trainer'),
      lastMessage: model.lastMessagePreview,
      avatarUrl: participant?.profileImageUrl,
      updatedAt: model.sortDate,
      isParticipantActive: participantStatus == 'ACTIVE',
    );
  }

  ChatContact copyWith({
    String? id,
    String? memberUserId,
    String? trainerUserId,
    String? participantUserId,
    String? name,
    String? lastMessage,
    String? avatarUrl,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isParticipantActive,
  }) {
    return ChatContact(
      id: id ?? this.id,
      memberUserId: memberUserId ?? this.memberUserId,
      trainerUserId: trainerUserId ?? this.trainerUserId,
      participantUserId: participantUserId ?? this.participantUserId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isParticipantActive: isParticipantActive ?? this.isParticipantActive,
    );
  }
}

class ChatController extends GetxController {
  ChatController({
    ChatService? chatService,
    ChatSocketService? socketService,
    UserService? userService,
  }) : _chatService = chatService ?? ChatService(),
       _socketService = socketService ?? ChatSocketService(),
       _userService = userService ?? UserService();

  final ChatService _chatService;
  final ChatSocketService _socketService;
  final UserService _userService;

  final messages = <ChatMessage>[].obs;
  final contacts = <ChatContact>[].obs;
  final selectedContact = Rxn<ChatContact>();
  final isLoadingConversations = false.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final isSendingImage = false.obs;
  final isStartingConversation = false.obs;
  final isParticipantTyping = false.obs;
  final isSocketConnected = false.obs;
  final messagesError = ''.obs;
  final conversationsError = ''.obs;
  final searchQuery = ''.obs;
  final composerText = ''.obs;

  final messageController = TextEditingController();
  final searchController = TextEditingController();

  final List<StreamSubscription<Map<String, dynamic>>> _subscriptions = [];
  final Map<String, Timer> _pendingFallbackTimers = {};
  Timer? _participantTypingTimer;
  Timer? _typingStopTimer;
  String? _currentUserId;
  String? _joinedConversationId;

  List<ChatContact> get filteredContacts {
    final query = searchQuery.value.trim().toLowerCase();
    final visible = query.isEmpty
        ? contacts.toList()
        : contacts.where((contact) {
            return contact.name.toLowerCase().contains(query) ||
                contact.lastMessage.toLowerCase().contains(query);
          }).toList();

    visible.sort((a, b) {
      final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return visible;
  }

  bool get canSend =>
      composerText.value.trim().isNotEmpty && !isSending.value;

  bool get canPickImage => !isSendingImage.value;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    messageController.addListener(_handleComposerChanged);
    _bindSocketEvents();
    unawaited(fetchConversations());
  }

  Future<void> fetchConversations({bool showError = false}) async {
    try {
      isLoadingConversations.value = true;
      conversationsError.value = '';
      await _loadCurrentUserId();

      final response = await _chatService.getConversations();
      contacts.assignAll(
        response.map(
          (conversation) => ChatContact.fromModel(
            conversation,
            currentUserId: _currentUserId,
          ),
        ),
      );
      _refreshSelectedContact();
    } on ApiException catch (error) {
      conversationsError.value = error.message;
      if (showError) _showError('Messages failed', error.message);
    } catch (_) {
      conversationsError.value = 'Could not load conversations.';
      if (showError) _showError('Messages failed', conversationsError.value);
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> openConversation(ChatContact contact) async {
    selectedContact.value = contact;
    await _connectSocket();
    _joinConversation(contact.id);
    await fetchMessages(contact.id, showError: true);
    markSeen(contact.id);
  }

  void closeActiveConversation() {
    final conversationId = _joinedConversationId;
    if (conversationId != null) {
      _socketService.leave(conversationId);
    }
    _joinedConversationId = null;
    isParticipantTyping.value = false;
    _typingStopTimer?.cancel();
    _participantTypingTimer?.cancel();
  }

  Future<ChatContact?> startConversationWithTrainer({
    required String trainerUserId,
    String? trainerName,
    String? avatarUrl,
  }) async {
    if (trainerUserId.trim().isEmpty) {
      _showError('Chat unavailable', 'Trainer user id is missing.');
      return null;
    }

    try {
      isStartingConversation.value = true;
      await _loadCurrentUserId();
      final conversation = await _chatService.startConversation(
        trainerUserId: trainerUserId.trim(),
      );
      var contact = ChatContact.fromModel(
        conversation,
        currentUserId: _currentUserId,
      );
      if (contact.id.isEmpty) {
        throw const ApiException('Conversation id not found');
      }
      if (contact.name == 'Trainer' && trainerName != null) {
        contact = contact.copyWith(name: trainerName);
      }
      if (contact.avatarUrl == null && avatarUrl != null) {
        contact = contact.copyWith(avatarUrl: avatarUrl);
      }

      _upsertContact(contact);
      await openConversation(contact);
      return selectedContact.value ?? contact;
    } on ApiException catch (error) {
      final existing = await _findExistingConversationForTrainer(
        trainerUserId.trim(),
      );
      if (existing != null) {
        await openConversation(existing);
        return existing;
      }
      _showError('Chat failed', _friendlyChatStartError(error));
    } catch (_) {
      _showError('Chat failed', 'Could not start the conversation.');
    } finally {
      isStartingConversation.value = false;
    }

    return null;
  }

  Future<ChatContact?> _findExistingConversationForTrainer(
    String trainerUserId,
  ) async {
    try {
      final response = await _chatService.getConversations();
      ChatContact? contact;
      for (final item in response.map(
        (conversation) => ChatContact.fromModel(
          conversation,
          currentUserId: _currentUserId,
        ),
      )) {
        if (item.trainerUserId == trainerUserId) {
          contact = item;
          break;
        }
      }
      if (contact != null) _upsertContact(contact);
      return contact;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchMessages(
    String conversationId, {
    bool showError = false,
  }) async {
    if (conversationId.trim().isEmpty) return;

    try {
      isLoadingMessages.value = true;
      messagesError.value = '';
      await _loadCurrentUserId();

      final response = await _chatService.getMessages(conversationId);
      response.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

      messages.assignAll(
        _dedupeMessages(
          response.map(
            (message) =>
                ChatMessage.fromModel(message, currentUserId: _currentUserId),
          ),
        ),
      );
      markSeen(conversationId);
    } on ApiException catch (error) {
      messagesError.value = error.message;
      if (showError) _showError('Messages failed', error.message);
    } catch (_) {
      messagesError.value = 'Could not load messages.';
      if (showError) _showError('Messages failed', messagesError.value);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final contact = selectedContact.value;
    final text = messageController.text.trim();

    if (contact == null || contact.id.isEmpty || text.isEmpty) return;

    await _loadCurrentUserId();
    final now = DateTime.now();
    final pendingId = 'local-${now.microsecondsSinceEpoch}';
    final pending = ChatMessage(
      id: pendingId,
      conversationId: contact.id,
      senderUserId: _currentUserId ?? '',
      text: text,
      isMe: true,
      time: _formatMessageTime(now),
      createdAt: now,
      isPending: true,
    );

    messageController.clear();
    _addOrReplaceMessage(pending);
    _upsertContact(contact.copyWith(lastMessage: text, updatedAt: now));
    _sendTyping(false);

    final sentOverSocket = await _sendMessageOverSocket(
      conversationId: contact.id,
      text: text,
      pendingId: pendingId,
    );

    if (!sentOverSocket) {
      await _sendMessageOverRest(
        conversationId: contact.id,
        text: text,
        pendingId: pendingId,
      );
    }
  }

  Future<void> pickAndSendImage(ImageSource source) async {
    final contact = selectedContact.value;
    if (contact == null || contact.id.isEmpty || isSendingImage.value) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
      );
      if (picked == null) return;

      isSendingImage.value = true;
      final upload = await _uploadChatImage(File(picked.path));
      await _sendImageMessage(
        conversationId: contact.id,
        attachmentUrl: upload.url,
        attachmentType: upload.contentType,
      );
    } on ApiException catch (error) {
      _showError('Image failed', error.message);
    } catch (_) {
      _showError('Image failed', 'Could not send the image.');
    } finally {
      isSendingImage.value = false;
    }
  }

  Future<_ChatImageUploadResult> _uploadChatImage(File file) async {
    // TODO: Wire this to the app's shared media upload endpoint when it is
    // available. Chat image sending is intentionally isolated here so the UI
    // and message flow are ready without introducing a role-specific API.
    throw const ApiException('Image upload API is not available yet.');
  }

  Future<void> _sendImageMessage({
    required String conversationId,
    required String attachmentUrl,
    required String attachmentType,
  }) async {
    await _loadCurrentUserId();
    final contact = selectedContact.value;
    final now = DateTime.now();
    final pendingId = 'local-${now.microsecondsSinceEpoch}';
    final pending = ChatMessage(
      id: pendingId,
      conversationId: conversationId,
      senderUserId: _currentUserId ?? '',
      text: '',
      isMe: true,
      time: _formatMessageTime(now),
      createdAt: now,
      messageType: 'IMAGE',
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      isPending: true,
    );

    _addOrReplaceMessage(pending);
    if (contact != null) {
      _upsertContact(contact.copyWith(lastMessage: 'Photo', updatedAt: now));
    }
    _sendTyping(false);

    final sentOverSocket = await _sendImageOverSocket(
      conversationId: conversationId,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      pendingId: pendingId,
    );

    if (!sentOverSocket) {
      await _sendImageOverRest(
        conversationId: conversationId,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
        pendingId: pendingId,
      );
    }
  }

  void markSeen(String conversationId) {
    if (conversationId.isEmpty) return;
    _socketService.emitSeen(conversationId);
    unawaited(_markSeenRest(conversationId));
  }

  Future<bool> _sendMessageOverSocket({
    required String conversationId,
    required String text,
    required String pendingId,
  }) async {
    await _connectSocket();
    final emitted = _socketService.sendText(
      conversationId: conversationId,
      text: text,
    );

    if (!emitted) return false;

    _pendingFallbackTimers[pendingId]?.cancel();
    _pendingFallbackTimers[pendingId] = Timer(const Duration(seconds: 6), () {
      final stillPending = messages.any(
        (message) => message.id == pendingId && message.isPending,
      );
      if (stillPending) {
        final pendingIndex = messages.indexWhere(
          (message) => message.id == pendingId && message.isPending,
        );
        if (pendingIndex != -1 &&
            _findDuplicateMessageIndex(messages[pendingIndex]) != -1) {
          messages.removeAt(pendingIndex);
          return;
        }

        unawaited(
          _sendMessageOverRest(
            conversationId: conversationId,
            text: text,
            pendingId: pendingId,
          ),
        );
      }
    });

    return true;
  }

  Future<bool> _sendImageOverSocket({
    required String conversationId,
    required String attachmentUrl,
    required String attachmentType,
    required String pendingId,
  }) async {
    await _connectSocket();
    final emitted = _socketService.sendImage(
      conversationId: conversationId,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );

    if (!emitted) return false;

    _pendingFallbackTimers[pendingId]?.cancel();
    _pendingFallbackTimers[pendingId] = Timer(const Duration(seconds: 6), () {
      final stillPending = messages.any(
        (message) => message.id == pendingId && message.isPending,
      );
      if (stillPending) {
        final pendingIndex = messages.indexWhere(
          (message) => message.id == pendingId && message.isPending,
        );
        if (pendingIndex != -1 &&
            _findDuplicateMessageIndex(messages[pendingIndex]) != -1) {
          messages.removeAt(pendingIndex);
          return;
        }

        unawaited(
          _sendImageOverRest(
            conversationId: conversationId,
            attachmentUrl: attachmentUrl,
            attachmentType: attachmentType,
            pendingId: pendingId,
          ),
        );
      }
    });

    return true;
  }

  Future<void> _sendMessageOverRest({
    required String conversationId,
    required String text,
    required String pendingId,
  }) async {
    try {
      isSending.value = true;
      final response = await _chatService.sendMessage(
        conversationId: conversationId,
        text: text,
      );
      _pendingFallbackTimers.remove(pendingId)?.cancel();
      _replacePendingMessage(
        pendingId,
        ChatMessage.fromModel(response, currentUserId: _currentUserId),
      );
    } on ApiException catch (error) {
      _markPendingFailed(pendingId);
      messageController.text = text;
      _showError('Message failed', error.message);
    } catch (_) {
      _markPendingFailed(pendingId);
      messageController.text = text;
      _showError('Message failed', 'Could not send your message.');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _sendImageOverRest({
    required String conversationId,
    required String attachmentUrl,
    required String attachmentType,
    required String pendingId,
  }) async {
    try {
      isSending.value = true;
      final response = await _chatService.sendMessage(
        conversationId: conversationId,
        text: '',
        messageType: 'IMAGE',
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
      _pendingFallbackTimers.remove(pendingId)?.cancel();
      _replacePendingMessage(
        pendingId,
        ChatMessage.fromModel(response, currentUserId: _currentUserId),
      );
    } on ApiException catch (error) {
      _markPendingFailed(pendingId);
      _showError('Image failed', error.message);
    } catch (_) {
      _markPendingFailed(pendingId);
      _showError('Image failed', 'Could not send the image.');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _markSeenRest(String conversationId) async {
    try {
      await _chatService.markSeen(conversationId);
      final contact = selectedContact.value;
      if (contact != null && contact.id == conversationId) {
        final updated = contact.copyWith(unreadCount: 0);
        selectedContact.value = updated;
        _upsertContact(updated);
      }
    } catch (_) {}
  }

  Future<void> _connectSocket() async {
    await _socketService.connect();
    isSocketConnected.value = _socketService.isConnected;
  }

  void _joinConversation(String conversationId) {
    if (_joinedConversationId == conversationId) return;
    closeActiveConversation();
    _joinedConversationId = conversationId;
    _socketService.join(conversationId);
  }

  void _bindSocketEvents() {
    _subscriptions.addAll([
      _socketService.messages.listen(_handleSocketMessage),
      _socketService.typing.listen(_handleSocketTyping),
      _socketService.seen.listen(_handleSocketSeen),
      _socketService.status.listen(_handleSocketStatus),
      _socketService.userDisconnected.listen(_handleSocketDisconnected),
    ]);
  }

  void _handleSocketMessage(Map<String, dynamic> payload) {
    final model = ChatMessageModel.fromJson(readMapPayload(payload));
    if (model.id.isEmpty) return;

    final message = ChatMessage.fromModel(
      model,
      currentUserId: _currentUserId,
    );
    _addOrReplaceMessage(message);

    final contact = selectedContact.value;
    if (contact != null && contact.id == model.conversationId) {
      _upsertContact(
        contact.copyWith(
          lastMessage: message.messageType == 'IMAGE' ? 'Photo' : message.text,
          updatedAt: message.createdAt ?? DateTime.now(),
        ),
      );
      if (!message.isMe) markSeen(model.conversationId);
    } else {
      unawaited(fetchConversations());
    }
  }

  void _handleSocketTyping(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString();
    if (conversationId != selectedContact.value?.id) return;

    final senderUserId = payload['senderUserId']?.toString();
    if (senderUserId != null && senderUserId == _currentUserId) return;

    final isTyping = payload['isTyping'] == true;
    isParticipantTyping.value = isTyping;
    _participantTypingTimer?.cancel();
    if (isTyping) {
      _participantTypingTimer = Timer(const Duration(seconds: 3), () {
        isParticipantTyping.value = false;
      });
    }
  }

  void _handleSocketSeen(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString();
    if (conversationId == null || conversationId != selectedContact.value?.id) {
      return;
    }

    final seenAt = DateTime.tryParse(payload['seenAt']?.toString() ?? '') ??
        DateTime.now();
    messages.assignAll(
      messages.map((message) {
        if (!message.isMe || message.seenAt != null) return message;
        return message.copyWith(seenAt: seenAt);
      }),
    );
  }

  void _handleSocketStatus(Map<String, dynamic> payload) {
    final userId =
        payload['userId']?.toString() ??
        payload['trainerUserId']?.toString() ??
        payload['memberUserId']?.toString();
    final status =
        payload['status']?.toString() ??
        payload['trainerStatus']?.toString() ??
        payload['memberStatus']?.toString();
    if (userId == null || status == null) return;

    final active = status.toUpperCase() == 'ACTIVE';
    for (var index = 0; index < contacts.length; index++) {
      final contact = contacts[index];
      if (contact.participantUserId == userId ||
          contact.trainerUserId == userId ||
          contact.memberUserId == userId) {
        contacts[index] = contact.copyWith(isParticipantActive: active);
      }
    }
    _refreshSelectedContact();
  }

  void _handleSocketDisconnected(Map<String, dynamic> payload) {
    final userId =
        payload['userId']?.toString() ??
        payload['trainerUserId']?.toString() ??
        payload['memberUserId']?.toString();
    if (userId == null) return;

    for (var index = 0; index < contacts.length; index++) {
      final contact = contacts[index];
      if (contact.participantUserId == userId ||
          contact.trainerUserId == userId ||
          contact.memberUserId == userId) {
        contacts[index] = contact.copyWith(isParticipantActive: false);
      }
    }
    _refreshSelectedContact();
  }

  void _handleComposerChanged() {
    composerText.value = messageController.text;
    _sendTyping(true);
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(milliseconds: 1400), () {
      _sendTyping(false);
    });
  }

  void _sendTyping(bool isTyping) {
    final conversationId = selectedContact.value?.id;
    if (conversationId == null || conversationId.isEmpty) return;
    _socketService.emitTyping(
      conversationId: conversationId,
      isTyping: isTyping,
    );
  }

  void _addOrReplaceMessage(ChatMessage message) {
    if (message.id.isNotEmpty && !message.id.startsWith('local-')) {
      final existingIndex = messages.indexWhere((item) => item.id == message.id);
      if (existingIndex != -1) {
        messages[existingIndex] = message;
        return;
      }

      final pendingIndex = messages.indexWhere((item) {
        return item.isPending &&
            item.text == message.text &&
            item.messageType == message.messageType &&
            item.conversationId == message.conversationId;
      });
      if (pendingIndex != -1) {
        _pendingFallbackTimers.remove(messages[pendingIndex].id)?.cancel();
        messages[pendingIndex] = message;
        return;
      }

      final duplicateIndex = _findDuplicateMessageIndex(message);
      if (duplicateIndex != -1) {
        messages[duplicateIndex] = _mergeDuplicateMessage(
          messages[duplicateIndex],
          message,
        );
        return;
      }
    }

    messages.add(message);
    _sortMessages();
  }

  List<ChatMessage> _dedupeMessages(Iterable<ChatMessage> source) {
    final unique = <ChatMessage>[];
    for (final message in source) {
      final idIndex = unique.indexWhere(
        (item) => item.id.isNotEmpty && item.id == message.id,
      );
      if (idIndex != -1) {
        unique[idIndex] = _mergeDuplicateMessage(unique[idIndex], message);
        continue;
      }

      final duplicateIndex = unique.indexWhere(
        (item) => _isLikelyDuplicateMessage(item, message),
      );
      if (duplicateIndex != -1) {
        unique[duplicateIndex] = _mergeDuplicateMessage(
          unique[duplicateIndex],
          message,
        );
        continue;
      }

      unique.add(message);
    }

    unique.sort(_compareMessages);
    return unique;
  }

  int _findDuplicateMessageIndex(ChatMessage message) {
    return messages.indexWhere((item) {
      if (item.id.isNotEmpty &&
          message.id.isNotEmpty &&
          item.id == message.id) {
        return false;
      }
      return _isLikelyDuplicateMessage(item, message);
    });
  }

  bool _isLikelyDuplicateMessage(ChatMessage a, ChatMessage b) {
    if (a.conversationId != b.conversationId) return false;
    if (a.messageType != b.messageType) return false;
    if (a.text.trim() != b.text.trim()) return false;
    if ((a.attachmentUrl ?? '') != (b.attachmentUrl ?? '')) return false;
    if ((a.attachmentType ?? '') != (b.attachmentType ?? '')) return false;

    final sameSender = a.senderUserId.isNotEmpty && b.senderUserId.isNotEmpty
        ? a.senderUserId == b.senderUserId
        : a.isMe == b.isMe;
    if (!sameSender) return false;

    final aDate = a.createdAt;
    final bDate = b.createdAt;
    if (aDate == null || bDate == null) return a.time == b.time;

    return aDate.difference(bDate).abs() <= const Duration(seconds: 12);
  }

  ChatMessage _mergeDuplicateMessage(ChatMessage current, ChatMessage incoming) {
    if (current.isPending && !incoming.isPending) return incoming;
    if (current.isFailed && !incoming.isFailed) return incoming;
    if (current.id.startsWith('local-') && !incoming.id.startsWith('local-')) {
      return incoming;
    }
    if (current.seenAt == null && incoming.seenAt != null) {
      return current.copyWith(seenAt: incoming.seenAt);
    }
    return current;
  }

  void _sortMessages() {
    messages.sort((a, b) {
      return _compareMessages(a, b);
    });
  }

  int _compareMessages(ChatMessage a, ChatMessage b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aDate.compareTo(bDate);
  }

  void _replacePendingMessage(String pendingId, ChatMessage replacement) {
    final index = messages.indexWhere((message) => message.id == pendingId);
    if (index == -1) {
      _addOrReplaceMessage(replacement);
      return;
    }
    messages[index] = replacement.copyWith(isPending: false);
  }

  void _markPendingFailed(String pendingId) {
    final index = messages.indexWhere((message) => message.id == pendingId);
    if (index == -1) return;
    messages[index] = messages[index].copyWith(
      isPending: false,
      isFailed: true,
    );
  }

  void _upsertContact(ChatContact contact) {
    final index = contacts.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      contacts.add(contact);
    } else {
      contacts[index] = contact;
    }
    _refreshSelectedContact();
  }

  void _refreshSelectedContact() {
    final selected = selectedContact.value;
    if (selected == null) return;

    final updated = contacts.firstWhereOrNull((item) => item.id == selected.id);
    if (updated != null) selectedContact.value = updated;
  }

  Future<void> _loadCurrentUserId() async {
    if (_currentUserId != null) return;

    try {
      final user = await _userService.getCurrentUser();
      _currentUserId = user.id;
    } catch (_) {}
  }

  void _showError(String title, String message) {
    showAppSnackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _friendlyChatStartError(ApiException error) {
    final message = error.message;
    if (error.statusCode == 500 ||
        message.contains('Prisma') ||
        message.contains('chatConversation.upsert')) {
      return 'Could not start the chat right now. Please try again shortly.';
    }
    return message;
  }

  @override
  void onClose() {
    closeActiveConversation();
    for (final timer in _pendingFallbackTimers.values) {
      timer.cancel();
    }
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _typingStopTimer?.cancel();
    _participantTypingTimer?.cancel();
    unawaited(_socketService.dispose());
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

String _formatMessageTime(DateTime? value) {
  if (value == null) return 'Now';
  return DateFormat('hh:mm a').format(value.toLocal());
}

class _ChatImageUploadResult {
  final String url;
  final String contentType;

  const _ChatImageUploadResult({
    required this.url,
    required this.contentType,
  });
}
