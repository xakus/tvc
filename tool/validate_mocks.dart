// Проверка JSON-фикстур mock-режима (R-DEV-4, spec/03_dev_environment.md).
//
// Запуск (без Flutter, только Dart SDK):
//   dart run tool/validate_mocks.dart
//   dart run tool/validate_mocks.dart --openapi <файл.yaml|файл.json|папка>[,<ещё>]
//   dart run tool/validate_mocks.dart --mock-dir assets/mock --strict
//
// Что проверяется:
//   1. Каждый assets/mock/*.json парсится как JSON-объект.
//   2. В файле есть поле `_endpoint` («МЕТОД /путь») и обёртка ApiResponse
//      (`success`, `code`, `message`, `language`, `data`, `correlationId`, `serverTime`).
//      Для файлов ошибок (`success: false`) `data` должен быть null, `code` != OK.
//   3. Если найден OpenAPI (по умолчанию — OpenAPI pscs v2 (`../pscs/src/main/resources/openapi/pscs-v2.yaml`)),
//      `_endpoint` сверяется с `paths` спецификации (параметры `{id}` сравниваются как шаблон).
//      Отсутствующий endpoint — предупреждение (с флагом --strict — ошибка).
//   Если OpenAPI-файла ещё нет — печатается предупреждение, скрипт не падает.
//
// Код выхода: 0 — всё в порядке (предупреждения допустимы), 1 — есть ошибки.
//
// Зависимостей от пакетов нет намеренно: скрипт должен работать в CI до `flutter pub get`
// и не тянуть YAML-парсер в pubspec приложения. Поэтому YAML читается построчно —
// этого достаточно для стандартного OpenAPI (`paths:` → `  /путь:` → `    get:`).

import 'dart:convert';
import 'dart:io';

/// OpenAPI по умолчанию (относительно корня проекта).
const String defaultOpenApi = '../pscs/src/main/resources/openapi/pscs-v2.yaml';

/// Папка с фикстурами по умолчанию.
const String defaultMockDir = 'assets/mock';

/// Допустимые языки ответа (R-CMS-2 / R-PSCS-90).
const Set<String> allowedLanguages = {'ru', 'en', 'az'};

/// Допустимые HTTP-методы в `_endpoint`.
const Set<String> httpMethods = {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'};

/// Обязательные поля обёртки ApiResponse (R-CMS-2).
const List<String> apiResponseFields = [
  'success',
  'code',
  'message',
  'language',
  'data',
  'correlationId',
  'serverTime',
];

/// Один endpoint спецификации: метод + путь (сегменты с `{param}` — шаблонные).
class SpecEndpoint {
  SpecEndpoint(this.method, this.path);

  final String method;
  final String path;

  /// Совпадает ли путь фикстуры с путём спецификации (с учётом `{id}`).
  bool matches(String method, String path) {
    if (this.method != method) return false;
    final a = _segments(this.path);
    final b = _segments(path);
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final isParam = a[i].startsWith('{') && a[i].endsWith('}');
      if (isParam) {
        if (b[i].isEmpty) return false;
        continue;
      }
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static List<String> _segments(String p) =>
      p.split('/').where((s) => s.isNotEmpty).toList();

  @override
  String toString() => '$method $path';
}

/// Загруженная спецификация: endpoint'ы + базовые пути из `servers`.
class OpenApiSpec {
  OpenApiSpec(this.source, this.endpoints, this.basePaths);

  final String source;
  final List<SpecEndpoint> endpoints;
  final List<String> basePaths;

  /// Есть ли `method path` в спецификации (напрямую или с учётом base path серверов).
  bool contains(String method, String path) {
    final candidates = <String>{path};
    for (final base in basePaths) {
      if (base.isNotEmpty && path.startsWith(base)) {
        candidates.add(path.substring(base.length));
      }
    }
    return endpoints.any((e) => candidates.any((c) => e.matches(method, c)));
  }
}

/// Результат проверки: списки ошибок и предупреждений.
class Report {
  final List<String> errors = [];
  final List<String> warnings = [];

  void error(String file, String msg) => errors.add('$file: $msg');

  void warn(String file, String msg) => warnings.add('$file: $msg');
}

void main(List<String> args) {
  final options = _parseArgs(args);
  if (options == null) {
    exit(2);
  }

  final projectRoot = _findProjectRoot();
  final mockDir = Directory(_resolve(projectRoot, options.mockDir));
  final report = Report();

  stdout.writeln('validate_mocks: проект ${projectRoot.path}');
  stdout.writeln('validate_mocks: фикстуры ${mockDir.path}');

  if (!mockDir.existsSync()) {
    stderr.writeln('ОШИБКА: папка фикстур не найдена: ${mockDir.path}');
    exit(1);
  }

  final files = mockDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('ОШИБКА: в ${mockDir.path} нет *.json файлов');
    exit(1);
  }

  // 1–2. Парсинг и обёртка ApiResponse.
  final endpoints = <String, String>{}; // файл -> "_endpoint"
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final endpoint = _checkFile(file, name, report);
    if (endpoint != null) endpoints[name] = endpoint;
  }

  // 3. Сверка с OpenAPI.
  final specs = _loadSpecs(projectRoot, options.openApi, report);
  if (specs.isEmpty) {
    report.warnings.add(
      'OpenAPI не найден (${options.openApi}) — сверка endpoint\'ов пропущена. '
      'Укажите путь флагом --openapi, когда спецификация появится.',
    );
  } else {
    for (final spec in specs) {
      stdout.writeln(
        'validate_mocks: OpenAPI ${spec.source} — ${spec.endpoints.length} endpoint(ов)',
      );
    }
    endpoints.forEach((name, endpoint) {
      final parts = endpoint.split(' ');
      final method = parts[0];
      final path = parts[1].split('?').first;
      final found = specs.any((s) => s.contains(method, path));
      if (!found) {
        final msg = 'endpoint "$method $path" отсутствует в OpenAPI';
        if (options.strict) {
          report.error(name, msg);
        } else {
          report.warn(name, msg);
        }
      }
    });
  }

  // Итог.
  stdout.writeln('');
  for (final w in report.warnings) {
    stdout.writeln('ПРЕДУПРЕЖДЕНИЕ: $w');
  }
  for (final e in report.errors) {
    stderr.writeln('ОШИБКА: $e');
  }
  stdout.writeln('');
  stdout.writeln(
    'validate_mocks: файлов ${files.length}, ошибок ${report.errors.length}, '
    'предупреждений ${report.warnings.length}',
  );
  exit(report.errors.isEmpty ? 0 : 1);
}

/// Параметры командной строки.
class Options {
  Options({required this.openApi, required this.mockDir, required this.strict});

  final String openApi;
  final String mockDir;
  final bool strict;
}

Options? _parseArgs(List<String> args) {
  var openApi = defaultOpenApi;
  var mockDir = defaultMockDir;
  var strict = false;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    String next() {
      if (i + 1 >= args.length) {
        stderr.writeln('Флагу $a нужно значение');
        exit(2);
      }
      return args[++i];
    }

    switch (a) {
      case '--openapi':
        openApi = next();
      case '--mock-dir':
        mockDir = next();
      case '--strict':
        strict = true;
      case '-h':
      case '--help':
        stdout.writeln(
          'Использование: dart run tool/validate_mocks.dart '
          '[--openapi <файл|папка>[,<ещё>]] [--mock-dir assets/mock] [--strict]',
        );
        return null;
      default:
        if (a.startsWith('--openapi=')) {
          openApi = a.substring('--openapi='.length);
        } else if (a.startsWith('--mock-dir=')) {
          mockDir = a.substring('--mock-dir='.length);
        } else {
          stderr.writeln('Неизвестный аргумент: $a');
          return null;
        }
    }
  }
  return Options(openApi: openApi, mockDir: mockDir, strict: strict);
}

/// Корень проекта: текущая папка, если в ней pubspec.yaml, иначе — родитель папки tool/.
Directory _findProjectRoot() {
  final cwd = Directory.current;
  if (File('${cwd.path}/pubspec.yaml').existsSync()) return cwd;
  final script = File.fromUri(Platform.script);
  return script.parent.parent;
}

String _resolve(Directory root, String path) =>
    path.startsWith('/') ? path : '${root.path}/$path';

/// Проверяет один файл фикстуры; возвращает `_endpoint` или null при ошибке парсинга.
String? _checkFile(File file, String name, Report report) {
  Object? json;
  try {
    json = jsonDecode(file.readAsStringSync());
  } on FormatException catch (e) {
    report.error(name, 'не парсится как JSON: ${e.message}');
    return null;
  }
  if (json is! Map<String, dynamic>) {
    report.error(name, 'корень должен быть JSON-объектом (ApiResponse)');
    return null;
  }

  // _endpoint
  final endpoint = json['_endpoint'];
  String? endpointOk;
  if (endpoint is! String ||
      !RegExp(r'^(GET|POST|PUT|PATCH|DELETE) /\S*$').hasMatch(endpoint)) {
    report.error(name, 'нет поля "_endpoint" вида "МЕТОД /путь" (получено: $endpoint)');
  } else {
    endpointOk = endpoint;
  }
  if (json.keys.isNotEmpty && json.keys.first != '_endpoint') {
    report.warn(name, 'поле "_endpoint" должно идти первым (документация)');
  }

  // Обёртка ApiResponse
  for (final field in apiResponseFields) {
    if (!json.containsKey(field)) {
      report.error(name, 'нет поля ApiResponse "$field"');
    }
  }
  final success = json['success'];
  final code = json['code'];
  final language = json['language'];
  final serverTime = json['serverTime'];
  final status = json['_status'];

  if (success is! bool) {
    report.error(name, '"success" должен быть bool');
  }
  if (code is! String || code.isEmpty) {
    report.error(name, '"code" должен быть непустой строкой');
  }
  if (json['message'] is! String) {
    report.error(name, '"message" должен быть строкой');
  }
  if (language is! String || !allowedLanguages.contains(language)) {
    report.error(name, '"language" должен быть одним из $allowedLanguages');
  }
  if (json['correlationId'] is! String) {
    report.error(name, '"correlationId" должен быть строкой');
  }
  if (serverTime is! String || DateTime.tryParse(serverTime) == null) {
    report.error(name, '"serverTime" должен быть ISO-8601 строкой');
  } else if (!serverTime.startsWith('2026-09-14')) {
    report.warn(name, '"serverTime" не на фиксированной демо-дате 2026-09-14');
  }
  if (status != null && (status is! int || status < 100 || status > 599)) {
    report.error(name, '"_status" должен быть HTTP-кодом (int)');
  }

  if (success == true) {
    if (code != 'OK') {
      report.error(name, 'успешный ответ должен иметь code "OK" (получено "$code")');
    }
    if (!json.containsKey('data') || json['data'] == null) {
      report.error(name, 'успешный ответ должен содержать непустой "data"');
    }
    if (status is int && status >= 400) {
      report.error(name, 'успешный ответ с HTTP-статусом $status');
    }
  } else if (success == false) {
    if (json['data'] != null) {
      report.error(name, 'в ответе-ошибке "data" должен быть null');
    }
    if (code == 'OK') {
      report.error(name, 'ответ-ошибка не может иметь code "OK"');
    }
    if (status is int && status < 400) {
      report.error(name, 'ответ-ошибка с HTTP-статусом $status');
    }
  }
  return endpointOk;
}

/// Загружает OpenAPI из файла/папки (через запятую можно перечислить несколько).
List<OpenApiSpec> _loadSpecs(Directory root, String option, Report report) {
  final specs = <OpenApiSpec>[];
  for (final raw in option.split(',')) {
    final p = raw.trim();
    if (p.isEmpty) continue;
    final path = _resolve(root, p);
    final type = FileSystemEntity.typeSync(path);
    if (type == FileSystemEntityType.directory) {
      final files = Directory(path)
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.yaml') ||
              f.path.endsWith('.yml') ||
              f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final f in files) {
        final s = _parseSpec(f, report);
        if (s != null) specs.add(s);
      }
    } else if (type == FileSystemEntityType.file) {
      final s = _parseSpec(File(path), report);
      if (s != null) specs.add(s);
    }
  }
  return specs;
}

OpenApiSpec? _parseSpec(File file, Report report) {
  final text = file.readAsStringSync();
  try {
    if (file.path.endsWith('.json')) {
      return _parseJsonSpec(file.path, jsonDecode(text));
    }
    return _parseYamlSpec(file.path, text);
  } on Object catch (e) {
    report.warn(file.path, 'не удалось прочитать OpenAPI: $e');
    return null;
  }
}

/// OpenAPI в JSON (`openapi.json` из springdoc).
OpenApiSpec? _parseJsonSpec(String source, Object? doc) {
  if (doc is! Map<String, dynamic>) return null;
  final endpoints = <SpecEndpoint>[];
  final paths = doc['paths'];
  if (paths is Map<String, dynamic>) {
    paths.forEach((path, item) {
      if (item is Map<String, dynamic>) {
        for (final m in item.keys) {
          final method = m.toUpperCase();
          if (httpMethods.contains(method)) {
            endpoints.add(SpecEndpoint(method, path));
          }
        }
      }
    });
  }
  final basePaths = <String>[];
  final servers = doc['servers'];
  if (servers is List) {
    for (final s in servers) {
      if (s is Map && s['url'] is String) {
        basePaths.add(_basePathOf(s['url'] as String));
      }
    }
  }
  return OpenApiSpec(source, endpoints, basePaths);
}

/// OpenAPI в YAML — построчный разбор блоков `paths:` и `servers:`.
OpenApiSpec _parseYamlSpec(String source, String text) {
  final endpoints = <SpecEndpoint>[];
  final basePaths = <String>[];
  final lines = text.split('\n');

  final pathLine = RegExp(r'''^(\s+)(?:'(/[^']*)'|"(/[^"]*)"|(/[^\s:]*)):\s*(#.*)?$''');
  final methodLine = RegExp(
    r'^(\s+)(get|post|put|patch|delete|head|options|GET|POST|PUT|PATCH|DELETE):\s*(#.*)?$',
  );
  final serverUrl = RegExp(r'''^\s*-\s*url:\s*['"]?([^'"#\s]+)['"]?''');

  String? section; // 'paths' | 'servers' | null
  int? pathIndent;
  String? currentPath;

  for (final rawLine in lines) {
    final line = rawLine.replaceAll('\r', '');
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;

    // Ключ верхнего уровня (без отступа).
    if (!line.startsWith(' ') && !line.startsWith('\t')) {
      final key = line.split(':').first.trim();
      section = (key == 'paths' || key == 'servers') ? key : null;
      pathIndent = null;
      currentPath = null;
      continue;
    }

    if (section == 'servers') {
      final m = serverUrl.firstMatch(line);
      if (m != null) basePaths.add(_basePathOf(m.group(1)!));
      continue;
    }

    if (section != 'paths') continue;

    final pm = pathLine.firstMatch(line);
    if (pm != null) {
      final indent = pm.group(1)!.length;
      pathIndent ??= indent;
      if (indent == pathIndent) {
        currentPath = pm.group(2) ?? pm.group(3) ?? pm.group(4);
        continue;
      }
    }
    final mm = methodLine.firstMatch(line);
    if (mm != null && currentPath != null && pathIndent != null) {
      final indent = mm.group(1)!.length;
      if (indent > pathIndent) {
        endpoints.add(SpecEndpoint(mm.group(2)!.toUpperCase(), currentPath));
      }
    }
  }
  return OpenApiSpec(source, endpoints, basePaths);
}

/// Путь из URL сервера (`https://host/api/v1` → `/api/v1`; `{var}` не поддерживается — берётся как есть).
String _basePathOf(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme) {
    final p = uri.path;
    return p == '/' ? '' : p.replaceAll(RegExp(r'/$'), '');
  }
  return url.startsWith('/') ? url.replaceAll(RegExp(r'/$'), '') : '';
}
