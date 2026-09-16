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
import 'package:tvc/widgets/blocked_card.dart';
import 'package:tvc/widgets/session_sales_card.dart';

import '../support/fonts.dart';

/// Экран по фикстурам (spec/03): заказы и суммы во время игры и в итоге (D-37), прайс-лист и скидки в ожидании,
/// экран блокировки, сообщение «не привязан».
void main() {
  setUpAll(loadAppFonts);

  Widget app(DeviceApi api) => MaterialApp(
    localizationsDelegates: const [
      TvcLocalizationDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: TvcLocalizationDelegate.supportedLocales,
    locale: const Locale('az'),
    home: HomePage(
      api: api,
      config: const AppConfig(apiUrl: 'http://test', deviceToken: 'dt_test'),
    ),
  );

  Future<void> show(WidgetTester tester, DeviceApi api) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    GpioService.stub = true; // без gpioset и процессов
    await tester.pumpWidget(app(api));
    await tester.pump(); // конфиг задан, состояние из фикстуры — микрозадачи
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('ACTIVE: заказы, товары, игра, итого', (tester) async {
    await show(tester, _FixtureApi('active_limited'));
    expect(find.text('PS Club Nizami'), findsOneWidget);
    expect(find.text('1 saat 5.00 azn'), findsOneWidget);
    expect(find.byType(SessionSalesCard), findsOneWidget);
    expect(find.text('Sifarişlər'), findsOneWidget);
    expect(find.text('Çay × 2'), findsOneWidget);
    expect(find.text('2.00 azn'), findsOneWidget);
    expect(find.text('Snickers × 1'), findsOneWidget);
    expect(find.text('Mallar'), findsOneWidget);
    expect(find.text('3.50 azn'), findsOneWidget);
    expect(find.text('Oyun'), findsOneWidget);
    expect(find.text('Cəmi'), findsOneWidget);
    expect(find.text('6.50 azn'), findsOneWidget);
    // время и скидка — как раньше; минуты от serverTime
    expect(find.textContaining('qalıb'), findsOneWidget);
    expect(find.textContaining('10% endirim'), findsOneWidget);
    expect(find.text('3 manat 0 qəpik'), findsOneWidget);
    // прайс-лист и скидки рядом
    expect(find.text('Qiymətlər'), findsOneWidget);
    expect(find.text('Fıstıq'), findsOneWidget);
    expect(find.text('Endirimlər'), findsOneWidget);
    expect(find.text('Bazar günü'), findsOneWidget);
    expect(find.text('5%'), findsWidgets);
    expect(find.byType(BlockedCard), findsNothing);
    await close(tester);
  });

  testWidgets('IDLE: без блока сумм, прайс-лист и скидки', (tester) async {
    await show(tester, _FixtureApi('idle'));
    expect(find.byType(SessionSalesCard), findsNothing);
    expect(find.text('Sifarişlər'), findsNothing);
    expect(find.text('Qiymətlər'), findsOneWidget);
    expect(find.text('Kalyan'), findsOneWidget);
    expect(find.text('15.00 azn'), findsOneWidget);
    expect(find.text('Endirimlər'), findsOneWidget);
    await close(tester);
  });

  testWidgets('FINISHED: чек с товарами и итогом', (tester) async {
    await show(tester, _FixtureApi('summary'));
    expect(find.byType(SessionSalesCard), findsOneWidget);
    expect(find.text('Çay × 2'), findsOneWidget);
    expect(find.text('Cəmi'), findsOneWidget);
    expect(find.text('6.50 azn'), findsOneWidget);
    expect(find.textContaining('oynamısız'), findsOneWidget);
    await close(tester);
  });

  testWidgets('BLOCKED: экран блокировки поверх', (tester) async {
    await show(tester, _FixtureApi('blocked'));
    expect(find.byType(BlockedCard), findsOneWidget);
    await close(tester);
  });

  testWidgets('токен не принят — сообщение о привязке', (tester) async {
    await show(tester, _UnauthorizedApi());
    expect(find.text('Ekran masaya bağlanmayıb'), findsOneWidget);
    await close(tester);
  });
}

class _UnauthorizedApi implements DeviceApi {
  @override
  Future<DeviceState> getState() async => throw const DeviceUnauthorized(401);

  @override
  Future<void> postStatus({required String version, required bool online, String? error}) async {}
}

/// Фикстура из файла (синхронно, без rootBundle — чтобы pump с фиктивным временем дождался состояния).
class _FixtureApi implements DeviceApi {
  final Map<String, dynamic> data;

  _FixtureApi(String name)
    : data = (jsonDecode(File('assets/mock/state_$name.json').readAsStringSync())
              as Map<String, dynamic>)['data']
          as Map<String, dynamic>;

  @override
  Future<DeviceState> getState() async => DeviceState.fromJson(MockDeviceApi.shiftToNow(data));

  @override
  Future<void> postStatus({required String version, required bool online, String? error}) async {}
}
