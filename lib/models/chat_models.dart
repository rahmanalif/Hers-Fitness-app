class ChatConversationModel {
  final String id;
  final String? trainerUserId;
  final String? memberUserId;
  final String title;
  final String lastMessage;
  final String? avatarUrl;
  final int unreadCount;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  const ChatConversationModel({
    required this.id,
    this.trainerUserId,
    this.memberUserId,
    required this.title,
    required this.lastMessage,
    this.avatarUrl,
    this.unreadCount = 0,
    this.updatedAt,
    this.raw = const <String, dynamic>{},
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final data = _object(json['data']) ?? json;
    final trainer = _object(data['trainer']) ?? _object(data['trainerUser']);
    final member = _object(data['member']) ?? _object(data['memberUser']);
    final otherUser =
        _object(data['otherUser']) ??
        _object(data['participant']) ??
        _object(data['user']) ??
        trainer ??
        member;
    final lastMessageMap =
        _object(data['lastMessage']) ?? _object(data['last_message']);

    final lastMessage =
        _readString(lastMessageMap, const ['text', 'message', 'content']) ??
        _readString(data, const ['lastMessage', 'last_message']) ??
        _readString(data, const ['lastMessageText', 'last_message_text']) ??
        '';

    return ChatConversationModel(
      id:
          _readString(data, const [
            'id',
            'conversationId',
            'conversation_id',
          ]) ??
          '',
      trainerUserId:
          _readString(data, const ['trainerUserId', 'trainer_user_id']) ??
          _readString(trainer, const ['id', 'userId', 'user_id']),
      memberUserId:
          _readString(data, const ['memberUserId', 'member_user_id']) ??
          _readString(member, const ['id', 'userId', 'user_id']),
      title: _displayName(otherUser) ?? 'Conversation',
      lastMessage: lastMessage,
      avatarUrl:
          _readString(otherUser, const [
            'image',
            'imageUrl',
            'image_url',
            'profileImage',
            'profileImageUrl',
            'profile_image',
            'profile_image_url',
            'avatar',
          ]) ??
          _readString(data, const ['avatarUrl', 'avatar_url']),
      unreadCount:
          _readInt(data, const [
            'unreadCount',
            'unread_count',
            'unseenCount',
          ]) ??
          0,
      updatedAt: _readDate(data, const [
        'updatedAt',
        'updated_at',
        'lastMessageAt',
        'last_message_at',
        'createdAt',
        'created_at',
      ]),
      raw: data,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String? conversationId;
  final String? senderUserId;
  final String text;
  final String messageType;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime? createdAt;
  final bool? isMine;
  final Map<String, dynamic> raw;

  const ChatMessageModel({
    required this.id,
    this.conversationId,
    this.senderUserId,
    required this.text,
    this.messageType = 'TEXT',
    this.attachmentUrl,
    this.attachmentType,
    this.createdAt,
    this.isMine,
    this.raw = const <String, dynamic>{},
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final data = _object(json['data']) ?? json;
    final sender = _object(data['sender']) ?? _object(data['senderUser']);

    return ChatMessageModel(
      id: _readString(data, const ['id', 'messageId', 'message_id']) ?? '',
      conversationId: _readString(data, const [
        'conversationId',
        'conversation_id',
      ]),
      senderUserId:
          _readString(data, const ['senderUserId', 'sender_user_id']) ??
          _readString(sender, const ['id', 'userId', 'user_id']),
      text:
          _readString(data, const ['text', 'message', 'content', 'body']) ?? '',
      messageType:
          _readString(data, const ['messageType', 'message_type', 'type']) ??
          'TEXT',
      attachmentUrl: _readString(data, const [
        'attachmentUrl',
        'attachment_url',
      ]),
      attachmentType: _readString(data, const [
        'attachmentType',
        'attachment_type',
      ]),
      createdAt: _readDate(data, const ['createdAt', 'created_at', 'sentAt']),
      isMine: _readBool(data, const ['isMine', 'isMe', 'mine']),
      raw: data,
    );
  }
}

List<Map<String, dynamic>> readListPayload(
  dynamic response,
  List<String> keys,
) {
  if (response is List) {
    return response.whereType<Map>().map(_stringMap).toList();
  }

  if (response is Map) {
    final map = _stringMap(response);
    for (final key in keys) {
      final value = map[key];
      if (value is List) {
        return value.whereType<Map>().map(_stringMap).toList();
      }
    }

    final data = map['data'];
    if (data is List) {
      return data.whereType<Map>().map(_stringMap).toList();
    }
    if (data is Map) {
      return readListPayload(data, keys);
    }
  }

  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> readMapPayload(dynamic response) {
  if (response is Map) {
    final map = _stringMap(response);
    final data = map['data'];
    if (data is Map) {
      final dataMap = _stringMap(data);
      for (final key in const ['conversation', 'message', 'item', 'result']) {
        final value = dataMap[key];
        if (value is Map) return _stringMap(value);
      }
      return dataMap;
    }
    for (final key in const ['conversation', 'message', 'item', 'result']) {
      final value = map[key];
      if (value is Map) return _stringMap(value);
    }
    return map;
  }

  return const <String, dynamic>{};
}

Map<String, dynamic>? _object(dynamic value) {
  if (value is Map) return _stringMap(value);
  return null;
}

Map<String, dynamic> _stringMap(Map value) {
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String? _displayName(Map<String, dynamic>? user) {
  if (user == null) return null;

  final firstName = _readString(user, const ['firstName', 'first_name']);
  final lastName = _readString(user, const ['lastName', 'last_name']);
  final combinedName = [
    firstName,
    lastName,
  ].where((value) => value != null && value.trim().isNotEmpty).join(' ');

  return _readString(user, const ['name', 'fullName', 'full_name']) ??
      (combinedName.isEmpty ? null : combinedName) ??
      _readString(user, const ['email']);
}

String? _readString(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;

  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }

  return null;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  final value = _readString(json, keys);
  if (value == null) return null;
  return int.tryParse(value) ?? double.tryParse(value)?.round();
}

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }

  return null;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  final value = _readString(json, keys);
  if (value == null) return null;
  return DateTime.tryParse(value);
}
