import 'dart:async';

import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/models/chat_models.dart';
import 'package:fitness/services/chat_service.dart';
import 'package:fitness/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fitness/utils/app_snackbar.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String messageType;
  final String? attachmentUrl;
  final String? attachmentType;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.messageType = 'TEXT',
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessage.fromModel(
    ChatMessageModel model, {
    required String? currentUserId,
  }) {
    final isMe =
        model.isMine ??
        (currentUserId != null &&
            model.senderUserId != null &&
            model.senderUserId == currentUserId);

    return ChatMessage(
      id: model.id,
      text: model.text,
      isMe: isMe,
      time: _formatMessageTime(model.createdAt),
      messageType: model.messageType,
      attachmentUrl: model.attachmentUrl,
      attachmentType: model.attachmentType,
    );
  }
}

class ChatContact {
  final String id;
  final String? trainerUserId;
  final String name;
  final String lastMessage;
  final String? avatarUrl;
  final int unreadCount;
  final DateTime? updatedAt;

  const ChatContact({
    required this.id,
    this.trainerUserId,
    required this.name,
    required this.lastMessage,
    this.avatarUrl,
    this.unreadCount = 0,
    this.updatedAt,
  });

  factory ChatContact.fromModel(ChatConversationModel model) {
    return ChatContact(
      id: model.id,
      trainerUserId: model.trainerUserId,
      name: model.title,
      lastMessage: model.lastMessage.isEmpty
          ? 'No messages yet'
          : model.lastMessage,
      avatarUrl: model.avatarUrl,
      unreadCount: model.unreadCount,
      updatedAt: model.updatedAt,
    );
  }

  ChatContact copyWith({
    String? id,
    String? trainerUserId,
    String? name,
    String? lastMessage,
    String? avatarUrl,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ChatContact(
      id: id ?? this.id,
      trainerUserId: trainerUserId ?? this.trainerUserId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatController extends GetxController {
  ChatController({ChatService? chatService, UserService? userService})
    : _chatService = chatService ?? ChatService(),
      _userService = userService ?? UserService();

  final ChatService _chatService;
  final UserService _userService;

  final messages = <ChatMessage>[].obs;
  final contacts = <ChatContact>[].obs;
  final selectedContact = Rxn<ChatContact>();
  final isLoadingConversations = false.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final isStartingConversation = false.obs;
  final searchQuery = ''.obs;

  final messageController = TextEditingController();
  final searchController = TextEditingController();

  String? _currentUserId;

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

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    fetchConversations();
  }

  Future<void> fetchConversations({bool showError = false}) async {
    try {
      isLoadingConversations.value = true;
      await _loadCurrentUserId();

      final response = await _chatService.getConversations();
      contacts.assignAll(response.map(ChatContact.fromModel));

      final selected = selectedContact.value;
      if (selected != null) {
        ChatContact? updated;
        for (final contact in contacts) {
          if (contact.id == selected.id) {
            updated = contact;
            break;
          }
        }
        if (updated != null) selectedContact.value = updated;
      }
    } on ApiException catch (error) {
      if (showError) {
        showAppSnackbar(
          'Messages failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (showError) {
        showAppSnackbar(
          'Messages failed',
          'Could not load conversations.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> openConversation(ChatContact contact) async {
    selectedContact.value = contact;
    await fetchMessages(contact.id, showError: true);
    unawaited(_markSeen(contact.id));
  }

  Future<ChatContact?> startConversationWithTrainer({
    required String trainerUserId,
    String? trainerName,
    String? avatarUrl,
  }) async {
    if (trainerUserId.trim().isEmpty) {
      showAppSnackbar(
        'Chat unavailable',
        'Trainer user id is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      isStartingConversation.value = true;
      final conversation = await _chatService.startConversation(
        trainerUserId: trainerUserId.trim(),
      );
      var contact = ChatContact.fromModel(conversation);
      if (contact.id.isEmpty) {
        throw const ApiException('Conversation id not found');
      }
      if (contact.name == 'Conversation' && trainerName != null) {
        contact = contact.copyWith(name: trainerName);
      }
      if (contact.avatarUrl == null && avatarUrl != null) {
        contact = contact.copyWith(avatarUrl: avatarUrl);
      }

      _upsertContact(contact);
      selectedContact.value = contact;
      await fetchMessages(contact.id, showError: true);
      return contact;
    } on ApiException catch (error) {
      showAppSnackbar(
        'Chat failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      showAppSnackbar(
        'Chat failed',
        'Could not start the conversation.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isStartingConversation.value = false;
    }

    return null;
  }

  Future<void> fetchMessages(
    String conversationId, {
    bool showError = false,
  }) async {
    if (conversationId.trim().isEmpty) return;

    try {
      isLoadingMessages.value = true;
      await _loadCurrentUserId();

      final response = await _chatService.getMessages(conversationId);
      response.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

      messages.assignAll(
        response.map(
          (message) =>
              ChatMessage.fromModel(message, currentUserId: _currentUserId),
        ),
      );
    } on ApiException catch (error) {
      if (showError) {
        showAppSnackbar(
          'Messages failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (showError) {
        showAppSnackbar(
          'Messages failed',
          'Could not load messages.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final contact = selectedContact.value;
    final text = messageController.text.trim();

    if (contact == null || contact.id.isEmpty || text.isEmpty) return;

    messageController.clear();

    try {
      isSending.value = true;
      final response = await _chatService.sendMessage(
        conversationId: contact.id,
        text: text,
      );
      messages.add(
        ChatMessage.fromModel(
          response,
          currentUserId: _currentUserId,
        ).copyAsMe(fallbackText: text),
      );
      _upsertContact(
        contact.copyWith(
          lastMessage: text,
          unreadCount: 0,
          updatedAt: DateTime.now(),
        ),
      );
    } on ApiException catch (error) {
      showAppSnackbar(
        'Message failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      messageController.text = text;
    } catch (_) {
      showAppSnackbar(
        'Message failed',
        'Could not send your message.',
        snackPosition: SnackPosition.BOTTOM,
      );
      messageController.text = text;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _markSeen(String conversationId) async {
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

  void _upsertContact(ChatContact contact) {
    final index = contacts.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      contacts.add(contact);
    } else {
      contacts[index] = contact;
    }
  }

  Future<void> _loadCurrentUserId() async {
    if (_currentUserId != null) return;

    try {
      final user = await _userService.getCurrentUser();
      _currentUserId = user.id;
    } catch (_) {}
  }

  @override
  void onClose() {
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

extension _ChatMessageFallback on ChatMessage {
  ChatMessage copyAsMe({required String fallbackText}) {
    return ChatMessage(
      id: id,
      text: text.isEmpty ? fallbackText : text,
      isMe: true,
      time: time,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );
  }
}

String _formatMessageTime(DateTime? value) {
  if (value == null) return 'Now';
  return DateFormat('hh:mm a').format(value.toLocal());
}
