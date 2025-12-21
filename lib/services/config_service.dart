import 'dart:convert';
import 'dart:io';

import '../models/app_config.dart';

class ConfigService {
  static const String _fileName = 'config.json';

  /// Загружает конфиг, создаёт его, если отсутствует
  static Future<AppConfig> loadConfig() async {
    final file = await _getConfigFile();

    // Проверяем существует ли файл И не пустой ли он
    if (!await file.exists() || (await file.length()) == 0) {
      print('Файл не существует или пустой, создаем с дефолтными значениями');

      final defaultConfig = AppConfig(
        apiUrl: "http://192.168.1.107:8899",
        updateUrl: "http://",
        priceHiddenTime: 3,
        deviceId: -3,
        version: 1,
        newVersion: 1,
      );

      // Сохраняем дефолтный конфиг
      final jsonString = jsonEncode(defaultConfig.toJson());
      await file.writeAsString(jsonString, flush: true);

      print('Записано в файл: $jsonString');

      return defaultConfig;
    }

    try {
      final content = await file.readAsString();
      // print('Прочитано из файла: $content');

      if (content.isEmpty) {
        throw FormatException('Файл пустой');
      }

      final jsonData = jsonDecode(content);
      return AppConfig.fromJson(jsonData);
    } catch (e) {
      print('Ошибка чтения файла: $e');

      // Создаем дефолтный конфиг при ошибке
      final defaultConfig = AppConfig(
        apiUrl: "http://192.168.1.107:8899",
        updateUrl: "http://",
        priceHiddenTime: 3,
        deviceId: -3,
        version: 1,
        newVersion: 1,
      );

      final jsonString = jsonEncode(defaultConfig.toJson());
      await file.writeAsString(jsonString, flush: true);

      return defaultConfig;
    }
  }

  /// Сохраняет конфигурацию в файл
  static Future<void> saveConfig(AppConfig config) async {
    final file = await _getConfigFile();
    final jsonString = jsonEncode(config.toJson());

    print('Сохраняем в ${file.path}');
    print('Данные: $jsonString');

    await file.writeAsString(jsonString, flush: true);

    // Проверяем что записалось
    final saved = await file.readAsString();
    print('Сохранено: $saved');
  }

  /// Возвращает путь к файлу config.json рядом с исполняемым файлом
  static Future<File> _getConfigFile() async {
    final exePath = File(Platform.resolvedExecutable).parent.path;
    final configPath = '$exePath/$_fileName';
    final configFile = File(configPath);
    // print('Файл существует: ${await configFile.exists()}');
    //
    // print('Путь к config: $configPath');

    // НЕ создаем файл здесь - пусть он создастся при записи

    return configFile;
  }
}
