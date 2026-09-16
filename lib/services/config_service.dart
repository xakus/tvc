import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_config.dart';

/// Чтение/запись `config.json` (R-TVC-4): на точке — `/etc/tvc/config.json` (0600), в dev — рядом с исполняемым
/// файлом. `--dart-define=API_URL` и `--dart-define=DEVICE_TOKEN` переопределяют файл (ноутбук разработчика).
class ConfigService {
  static const String systemPath = '/etc/tvc/config.json';
  static const String _fileName = 'config.json';

  static const String _defineApiUrl = String.fromEnvironment('API_URL');
  static const String _defineToken = String.fromEnvironment('DEVICE_TOKEN');

  static AppConfig? _cached;

  /// Конфиг с учётом `--dart-define`; при отсутствии файла — значения по умолчанию (без токена).
  static Future<AppConfig> loadConfig() async {
    if (_cached != null) {
      return _cached!;
    }
    AppConfig config = const AppConfig(
      apiUrl: 'http://192.168.1.107:8899',
      deviceToken: '',
    );
    try {
      final file = await _configFile();
      if (await file.exists() && await file.length() > 0) {
        final json = jsonDecode(await file.readAsString());
        if (json is Map<String, dynamic>) {
          config = AppConfig.fromJson(json);
        }
      }
    } catch (e) {
      debugPrint('config.json не прочитан: $e');
    }
    if (_defineApiUrl.isNotEmpty) {
      config = config.copyWith(apiUrl: _defineApiUrl);
    }
    if (_defineToken.isNotEmpty) {
      config = config.copyWith(deviceToken: _defineToken);
    }
    _cached = config;
    return config;
  }

  /// Сохранить (например, токен после привязки — 3.1); права 0600 на точке.
  static Future<void> saveConfig(AppConfig config) async {
    final file = await _configFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(config.toJson()),
      flush: true,
    );
    if (!Platform.isWindows) {
      await Process.run('chmod', ['600', file.path]);
    }
    _cached = config;
  }

  /// Сбросить кэш (тесты).
  @visibleForTesting
  static void reset() => _cached = null;

  /// `/etc/tvc/config.json`, если есть; иначе файл рядом с бинарником (dev).
  static Future<File> _configFile() async {
    final system = File(systemPath);
    if (await system.exists()) {
      return system;
    }
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return File('$exeDir/$_fileName');
  }
}
