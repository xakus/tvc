import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/device_state.dart';

/// pscs не принял токен устройства (401/403) — экран не привязан (R-TVC-5).
class DeviceUnauthorized implements Exception {
  final int status;
  const DeviceUnauthorized(this.status);

  @override
  String toString() => 'DeviceUnauthorized($status)';
}

/// Источник состояния стола: pscs по device API или фикстуры (`--dart-define=API_MODE=mock`).
abstract class DeviceApi {
  /// `GET /api/v1/device/state`.
  Future<DeviceState> getState();

  /// `POST /api/v1/device/status` — heartbeat раз в 60 с (R-TVC-20).
  Future<void> postStatus({
    required String version,
    required bool online,
    String? error,
  });

  /// Выбор реализации по `--dart-define`.
  static DeviceApi create({
    required String apiUrl,
    required String deviceToken,
  }) {
    const mode = String.fromEnvironment('API_MODE');
    if (mode == 'mock') {
      return MockDeviceApi(
        const String.fromEnvironment('MOCK_STATE', defaultValue: 'idle'),
      );
    }
    return HttpDeviceApi(apiUrl: apiUrl, deviceToken: deviceToken);
  }
}

/// Клиент device API pscs v2: `Authorization: Bearer <deviceToken>`, таймауты 5 с, ответы `ApiResponse{data}`.
class HttpDeviceApi implements DeviceApi {
  final Dio _dio;

  HttpDeviceApi({required String apiUrl, required String deviceToken})
    : _dio = Dio(
        BaseOptions(
          baseUrl: apiUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $deviceToken',
          },
          // 401/403 разбираем сами, остальное — исключение
          validateStatus: (s) => s != null && s < 500,
        ),
      );

  @override
  Future<DeviceState> getState() async {
    final received = DateTime.now();
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/device/state',
    );
    final data = _data(response);
    return DeviceState.fromJson(data, receivedAt: received);
  }

  @override
  Future<void> postStatus({
    required String version,
    required bool online,
    String? error,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/device/status',
      data: {'version': version, 'online': online, 'error': error},
    );
    _check(response);
  }

  void _check(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status == 401 || status == 403) {
      throw DeviceUnauthorized(status);
    }
    if (status != 200 && status != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'HTTP $status ${response.data?['code'] ?? ''}',
      );
    }
  }

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    _check(response);
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'нет data в ответе',
      );
    }
    return data;
  }
}

/// Фикстуры `assets/mock/state_<name>.json` (демо-набор spec/03): `serverTime` сдвигается к «сейчас»,
/// чтобы таймеры на экране шли как при живом сервере.
class MockDeviceApi implements DeviceApi {
  final String stateName;

  MockDeviceApi(this.stateName);

  @override
  Future<DeviceState> getState() async {
    final text = await rootBundle.loadString('assets/mock/state_$stateName.json');
    final json = jsonDecode(text) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    return DeviceState.fromJson(shiftToNow(data));
  }

  @override
  Future<void> postStatus({
    required String version,
    required bool online,
    String? error,
  }) async {
    debugPrint('mock heartbeat: $version online=$online error=$error');
  }

  /// Сдвинуть все моменты состояния так, чтобы `serverTime` стал текущим временем.
  @visibleForTesting
  static Map<String, dynamic> shiftToNow(Map<String, dynamic> data) {
    final serverTime = DateTime.parse(data['serverTime'] as String);
    final delta = DateTime.now().difference(serverTime);
    String shift(String iso) => DateTime.parse(iso).add(delta).toIso8601String();
    Map<String, dynamic> shiftKeys(Map<String, dynamic> m, List<String> keys) {
      final out = Map<String, dynamic>.of(m);
      for (final k in keys) {
        if (out[k] is String) {
          out[k] = shift(out[k] as String);
        }
      }
      return out;
    }

    final out = shiftKeys(data, ['serverTime']);
    if (out['session'] is Map<String, dynamic>) {
      out['session'] = shiftKeys(out['session'] as Map<String, dynamic>, [
        'startedAt',
        'plannedEndAt',
      ]);
    }
    if (out['reservation'] is Map<String, dynamic>) {
      out['reservation'] = shiftKeys(
        out['reservation'] as Map<String, dynamic>,
        ['reservedFrom', 'holdUntil'],
      );
    }
    if (out['lastReceipt'] is Map<String, dynamic>) {
      out['lastReceipt'] = shiftKeys(
        out['lastReceipt'] as Map<String, dynamic>,
        ['startedAt', 'stoppedAt', 'showUntil'],
      );
    }
    return out;
  }
}
