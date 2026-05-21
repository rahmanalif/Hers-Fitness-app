import 'dart:async';

import 'package:fitness/core/storage/token_storage.dart';
import 'package:fitness/utils/AppConstants/app_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  ChatSocketService({TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage();

  final TokenStorage _tokenStorage;
  io.Socket? _socket;

  final _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _seenController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _disconnectController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get typing => _typingController.stream;
  Stream<Map<String, dynamic>> get seen => _seenController.stream;
  Stream<Map<String, dynamic>> get status => _statusController.stream;
  Stream<Map<String, dynamic>> get userDisconnected =>
      _disconnectController.stream;

  bool get isConnected => _socket?.connected == true;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;

    final socketUrl = _socketUrl;
    if (socketUrl.isEmpty) return;

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) => debugPrint('Chat socket connected'));
    socket.onDisconnect((_) => debugPrint('Chat socket disconnected'));
    socket.onConnectError((error) {
      debugPrint('Chat socket connect error: $error');
    });
    socket.onError((error) => debugPrint('Chat socket error: $error'));

    socket.on('chat:message', (payload) {
      final map = _payloadMap(payload);
      if (map != null) _messageController.add(map);
    });
    socket.on('chat:typing', (payload) {
      final map = _payloadMap(payload);
      if (map != null) _typingController.add(map);
    });
    socket.on('chat:seen', (payload) {
      final map = _payloadMap(payload);
      if (map != null) _seenController.add(map);
    });
    socket.on('chat:status', (payload) {
      final map = _payloadMap(payload);
      if (map != null) _statusController.add(map);
    });
    socket.on('chat:userDisconnected', (payload) {
      final map = _payloadMap(payload);
      if (map != null) _disconnectController.add(map);
    });

    _socket = socket;
    socket.connect();
  }

  void join(String conversationId) {
    if (conversationId.isEmpty) return;
    _emit('chat:join', {'conversationId': conversationId});
  }

  void leave(String conversationId) {
    if (conversationId.isEmpty) return;
    _emit('chat:leave', {'conversationId': conversationId});
  }

  bool sendText({
    required String conversationId,
    required String text,
  }) {
    return _emit('chat:sendMessage', {
      'conversationId': conversationId,
      'messageType': 'TEXT',
      'text': text,
    });
  }

  bool sendImage({
    required String conversationId,
    required String attachmentUrl,
    required String attachmentType,
  }) {
    return _emit('chat:sendMessage', {
      'conversationId': conversationId,
      'messageType': 'IMAGE',
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    });
  }

  bool emitTyping({required String conversationId, required bool isTyping}) {
    return _emit('chat:typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  bool emitSeen(String conversationId) {
    if (conversationId.isEmpty) return false;
    return _emit('chat:seen', {'conversationId': conversationId});
  }

  bool _emit(String event, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || socket.connected != true) return false;
    socket.emit(event, payload);
    return true;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _messageController.close();
    await _typingController.close();
    await _seenController.close();
    await _statusController.close();
    await _disconnectController.close();
  }

  String get _socketUrl {
    final base = AppConstants.BASE_URL.trim();
    if (base.isEmpty) return '';

    var normalized = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    if (normalized.endsWith('/api')) {
      normalized = normalized.substring(0, normalized.length - 4);
    }
    return '$normalized/chat';
  }

  Map<String, dynamic>? _payloadMap(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
