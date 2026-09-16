import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tvc/models/device_state.dart';
import 'package:tvc/services/device_api.dart';

/// Модели device API: все фикстуры `assets/mock/state_*.json` разбираются, суммы D-37 на месте, деньги
/// форматируются как в прайс-листе, сдвиг времени mock-режима сохраняет длительности.
void main() {
  Map<String, dynamic> fixture(String name) =>
      (jsonDecode(File('assets/mock/state_$name.json').readAsStringSync())
              as Map<String, dynamic>)['data']
          as Map<String, dynamic>;

  test('все фикстуры состояния разбираются', () {
    final names = Directory('assets/mock')
        .listSync()
        .map((f) => f.path.split('/').last)
        .where((n) => n.startsWith('state_') && n.endsWith('.json'))
        .map((n) => n.substring(6, n.length - 5))
        .toList();
    expect(names.length, greaterThanOrEqualTo(6));
    for (final n in names) {
      final s = DeviceState.fromJson(fixture(n));
      expect(s.tableId, greaterThan(0), reason: n);
      expect(s.clubName, isNotEmpty, reason: n);
      expect(s.idle.products, isNotEmpty, reason: n);
    }
  });

  test('ACTIVE_LIMITED: заказы и суммы от pscs (D-37)', () {
    final s = DeviceState.fromJson(fixture('active_limited'));
    expect(s.isActive, isTrue);
    final session = s.session!;
    expect(session.sales.map((x) => '${x.productName}×${x.quantity}=${x.totalQepik}'),
        ['Çay×2=200', 'Snickers×1=150']);
    expect(session.salesTotalQepik, 350);
    expect(session.currentPriceQepik, 300);
    expect(session.grandTotalQepik, 650);
    expect(session.discountPercent, 10);
    expect(s.idle.autoScroll, isTrue);
    expect(s.idle.products.first.name, 'Fıstıq');
    expect(s.language, 'az');
  });

  test('FINISHED: чек с товарами', () {
    final s = DeviceState.fromJson(fixture('summary'));
    expect(s.isFinished, isTrue);
    expect(s.session, isNull);
    final r = s.lastReceipt!;
    expect(r.sales.length, 2);
    expect(r.grandTotalQepik, 650);
    expect(r.totalPercent, 10);
    expect(r.showUntil.isAfter(r.stoppedAt), isTrue);
  });

  test('деньги форматируются как в прайс-листе', () {
    expect(formatAzn(650), '6.50 azn');
    expect(formatAzn(80), '0.80 azn');
    expect(formatAzn(1500), '15.00 azn');
    expect(formatAzn(5), '0.05 azn');
    expect(formatAzn(-120), '-1.20 azn');
  });

  test('mock-режим сдвигает время к «сейчас», сохраняя длительности', () {
    final raw = fixture('active_limited');
    final shifted = MockDeviceApi.shiftToNow(raw);
    final s = DeviceState.fromJson(shifted);
    expect(DateTime.now().difference(s.serverTime).inSeconds.abs(), lessThan(5));
    final session = s.session!;
    expect(session.plannedEndAt!.difference(session.startedAt).inMinutes, 120);
    expect(s.serverTime.difference(session.startedAt).inMinutes, 40);
    // интерполяция: осталось ~80 минут
    expect(s.serverNow.isBefore(session.plannedEndAt!), isTrue);
  });
}
