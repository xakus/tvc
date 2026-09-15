import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/info_schedule.dart';

/// WebSocket-клиент для подключения к pscs /topic/tables.
/// Подключается к /ws-tv (raw WebSocket, без SockJS, без JWT — только deviceId).
/// При разрыве автоматически переподключается каждые 5 сек.
/// Fallback на polling в home_page.dart если WS недоступен.
class WsService {
  final int    _deviceId;
  final String _wsUrl;

  /// Вызывается при получении нового состояния стола для этого deviceId
  final void Function(InfoSchedule)? onTableUpdate;

  /// Вызывается при разрыве соединения — home_page переключается на polling
  final void Function()? onDisconnect;

  /// Вызывается при восстановлении соединения
  final void Function()? onReconnect;

  StompClient? _client;
  bool _active = false;

  bool get isConnected => _active;

  WsService({
    required String apiUrl,
    required int deviceId,
    this.onTableUpdate,
    this.onDisconnect,
    this.onReconnect,
  })  : _deviceId = deviceId,
        _wsUrl    = _buildWsUrl(apiUrl, deviceId);

  /// Конвертирует http://host:port в ws://host:port/ws-tv?deviceId=X
  static String _buildWsUrl(String apiUrl, int deviceId) {
    final base = apiUrl.replaceFirst(RegExp(r'^http'), 'ws');
    return '$base/ws-tv?deviceId=$deviceId';
  }

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: _wsUrl,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: _onWsError,
        onWebSocketDone: _onWsDone,
        onStompError: (f) => debugPrint('WS STOMP error: ${f.body}'),
      ),
    );
    _client!.activate();
  }

  void disconnect() {
    _active = false;
    _client?.deactivate();
    _client = null;
  }

  void _onConnect(StompFrame frame) {
    _active = true;
    debugPrint('WS connected — subscribing /topic/tables');
    onReconnect?.call();

    _client!.subscribe(
      destination: '/topic/tables',
      callback: _onMessage,
    );
  }

  void _onDisconnect(StompFrame frame) {
    _active = false;
    debugPrint('WS disconnected');
    onDisconnect?.call();
  }

  void _onWsError(dynamic error) {
    _active = false;
    debugPrint('WS socket error: $error');
    onDisconnect?.call();
  }

  void _onWsDone() {
    _active = false;
    debugPrint('WS socket done');
    onDisconnect?.call();
  }

  /// Парсит список всех столов и находит запись для нашего deviceId
  void _onMessage(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) return;
    try {
      final list = json.decode(body) as List<dynamic>;
      final entry = list.cast<Map<String, dynamic>>().firstWhere(
        (t) => (t['tableId'] ?? t['deviceId']) == _deviceId,
        orElse: () => {},
      );
      if (entry.isEmpty) return;
      final info = InfoSchedule.fromJson(entry);
      onTableUpdate?.call(info);
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }
}
