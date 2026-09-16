import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvc/localization/tvc_localization.dart';
import 'package:tvc/models/app_config.dart';
import 'package:tvc/models/device_state.dart';
import 'package:tvc/pages/home_page.dart';
import 'package:tvc/services/device_api.dart';
import 'package:tvc/services/gpio_service.dart';
import 'package:tvc/widgets/clock_widget.dart';

import '../support/fonts.dart';

/// Эталонные снимки экрана 1920×1080 по фикстурам (plan 3.0, `docs/design-baseline/`): дизайн зафиксирован (D-12),
/// любое расхождение — осознанное решение. Обновление: `flutter test --update-goldens test/pages/home_page_golden_test.dart`.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    // Часы на экране — фиксированная среда 16.09.2026, иначе снимок зависит от дня запуска
    ClockWidget.now = () => DateTime(2026, 9, 16, 12, 0);
  });
  tearDownAll(() => ClockWidget.now = DateTime.now);

  Future<void> golden(WidgetTester tester, String state) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    GpioService.stub = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          TvcLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: TvcLocalizationDelegate.supportedLocales,
        locale: const Locale('az'),
        home: HomePage(
          api: _FixedApi(state),
          config: const AppConfig(apiUrl: 'http://test', deviceToken: 'dt_test'),
        ),
      ),
    );
    await tester.pump();
    // Фон — asset-картинка, декодируется асинхронно: без явной предзагрузки первый снимок остаётся без фона
    await tester.runAsync(
      () => precacheImage(const AssetImage('assets/images/background.png'), tester.element(find.byType(HomePage))),
    );
    await tester.pump();
    await tester.pump();
    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('../goldens/state_$state.png'),
    );
    await tester.pumpWidget(const SizedBox());
  }

  for (final state in ['idle', 'active_limited', 'active_unlimited', 'summary', 'blocked', 'reserved']) {
    testWidgets('golden $state', (tester) => golden(tester, state));
  }
}

/// Фикстура с фиксированным временем (сдвиг к «сейчас» не применяется — снимок должен быть воспроизводимым):
/// `serverTime` фикстуры считается моментом получения.
class _FixedApi implements DeviceApi {
  final Map<String, dynamic> data;

  _FixedApi(String name)
    : data = (jsonDecode(File('assets/mock/state_$name.json').readAsStringSync())
              as Map<String, dynamic>)['data']
          as Map<String, dynamic>;

  @override
  Future<DeviceState> getState() async =>
      DeviceState.fromJson(data, receivedAt: DateTime.now()); // age ≈ 0 → минуты как в фикстуре

  @override
  Future<void> postStatus({required String version, required bool online, String? error}) async {}
}
