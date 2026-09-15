import 'dart:io';

import 'package:dio/dio.dart';

/// Скачивает и устанавливает обновление tvc.
/// Вызывается из home_page.dart при обнаружении новой версии.
class UpdateService {
  final Dio _dio;

  UpdateService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  /// Скачивает архив по [url] в /tmp/tvc_update.tar.gz.
  /// [onProgress] — прогресс 0.0..1.0
  Future<String> download(String url, {void Function(double)? onProgress}) async {
    const dest = '/tmp/tvc_update.tar.gz';
    await _dio.download(
      url,
      dest,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );
    return dest;
  }

  /// Распаковывает архив и запускает update.sh.
  /// После успешной установки — exit(0), systemd перезапустит приложение.
  Future<void> install(String archivePath) async {
    // Распаковываем в /opt/tvc/
    final extractResult = await Process.run(
      'tar',
      ['-xzf', archivePath, '-C', '/opt/tvc/'],
      runInShell: true,
    );
    if (extractResult.exitCode != 0) {
      throw Exception('Ошибка распаковки: ${extractResult.stderr}');
    }

    // Запускаем скрипт установки
    await Process.run('bash', ['/opt/tvc/update.sh'], runInShell: true);

    exit(0);
  }
}
