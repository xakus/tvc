import 'dart:io';

import 'package:flutter/foundation.dart';

/// Реле PlayStation через `gpioset` (Orange Pi). `--dart-define=GPIO=stub` — на ноутбуке только лог.
/// Ошибки не глотаются: последняя уходит в heartbeat `POST /device/status` (R-TVC-3).
class GpioService {
  /// Заглушка вместо `gpioset` (`--dart-define=GPIO=stub`; тесты выставляют напрямую).
  static bool stub = const String.fromEnvironment('GPIO') == 'stub';

  /// Линия реле питания PS (из config.json, по умолчанию 260).
  static int psPin = 260;

  /// Линия «экран включён» (индикатор), как в текущей прошивке.
  static const int screenPin = 259;

  static String? lastError;
  static bool? _psState;

  /// Включить/выключить PlayStation; повторная установка того же значения не дёргает реле.
  static Future<void> setPs(bool on) async {
    if (_psState == on) {
      return;
    }
    _psState = on;
    await _set(psPin, on);
  }

  static Future<void> setScreen(bool on) => _set(screenPin, on);

  static Future<void> _set(int pin, bool on) async {
    if (stub) {
      debugPrint('GPIO(stub): pin $pin = ${on ? 1 : 0}');
      return;
    }
    try {
      final result = await Process.run('gpioset', [
        'gpiochip0',
        '$pin=${on ? 1 : 0}',
      ], runInShell: true);
      if (result.exitCode != 0) {
        lastError = 'gpioset pin $pin: ${result.stderr}'.trim();
        debugPrint(lastError);
      } else {
        lastError = null;
      }
    } catch (e) {
      lastError = 'gpioset pin $pin: $e';
      debugPrint(lastError);
    }
  }
}
