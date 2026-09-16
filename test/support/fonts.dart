import 'dart:io';

import 'package:flutter/services.dart';

/// Загрузка шрифтов приложения в тесты: без них Flutter рисует «Ahem» с другими метриками, и раскладка
/// (высоты карточек 1920×1080) не совпадает с реальным экраном.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File(f);
      if (await file.exists()) {
        loader.addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
      }
    }
    await loader.load();
  }

  await load('AlumniSans', [
    'assets/fonts/alumni_sans/AlumniSans-Regular.ttf',
    'assets/fonts/alumni_sans/AlumniSans-Medium.ttf',
    'assets/fonts/alumni_sans/AlumniSans-SemiBold.ttf',
    'assets/fonts/alumni_sans/AlumniSans-Bold.ttf',
    'assets/fonts/alumni_sans/AlumniSans-ExtraBold.ttf',
    'assets/fonts/alumni_sans/AlumniSans-Light.ttf',
  ]);
  await load('Tektur', [
    'assets/fonts/tektur/Tektur-Regular.ttf',
    'assets/fonts/tektur/Tektur-Bold.ttf',
    'assets/fonts/tektur/Tektur-ExtraBold.ttf',
    'assets/fonts/tektur/Tektur-Black.ttf',
    'assets/fonts/tektur/Tektur-Medium.ttf',
  ]);
  await load('MartianMono', [
    'assets/fonts/martian_mono/MartianMono-Regular.ttf',
  ]);
  // Дата в часах рисуется шрифтом по умолчанию (Roboto по имени в теме Material); на Orange Pi это
  // системный sans-serif. В тестах подставляем Noto Sans, если он есть в системе, иначе останется «Ahem».
  await load('Roboto', ['/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf']);
}
