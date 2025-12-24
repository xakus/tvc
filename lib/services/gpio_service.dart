import 'dart:io';

class GpioService {
  static Future<void> setPi3(bool value) async {
    await Process.run(
      'gpioset',
      ['gpiochip0', '259=${value ? 1 : 0}'],
      runInShell: true,
    );
  }

  static Future<void> setPi4(bool value) async {
    await Process.run(
      'gpioset',
      ['gpiochip0', '260=${value ? 1 : 0}'],
      runInShell: true,
    );
  }
}
