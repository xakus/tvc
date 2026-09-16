import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvc/widgets/auto_scroll_list.dart';

/// Автопрокрутка (D-37): не помещается — едет, помещается — стоит; `step` сдвигает на строку без анимации и
/// возвращается в начало; `smooth` доезжает до конца линейно.
void main() {
  Widget host(Widget child, {double height = 200}) => MaterialApp(
    home: Center(child: SizedBox(width: 300, height: height, child: child)),
  );

  Widget list({required int count, required String mode}) => AutoScrollList(
    itemCount: count,
    itemExtent: 50,
    mode: mode,
    stepInterval: const Duration(seconds: 1),
    pauseAtEdges: const Duration(seconds: 1),
    pixelsPerSecond: 100,
    itemBuilder: (_, i) => SizedBox(height: 50, child: Text('row $i')),
  );

  testWidgets('помещается — не прокручивается', (tester) async {
    await tester.pumpWidget(host(list(count: 3, mode: 'step')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
    expect(scrollable.controller!.offset, 0);
  });

  testWidgets('step: строка за строкой и в начало', (tester) async {
    await tester.pumpWidget(host(list(count: 6, mode: 'step'))); // 300 px в окне 200
    await tester.pump();
    final controller = tester.widget<Scrollable>(find.byType(Scrollable)).controller!;
    await tester.pump(const Duration(seconds: 1));
    expect(controller.offset, 50);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.offset, 100); // = maxScrollExtent
    await tester.pump(const Duration(seconds: 1));
    expect(controller.offset, 0); // с конца — в начало
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('smooth: доезжает до конца и возвращается', (tester) async {
    await tester.pumpWidget(host(list(count: 6, mode: 'smooth')));
    await tester.pump();
    final controller = tester.widget<Scrollable>(find.byType(Scrollable)).controller!;
    await tester.pump(const Duration(seconds: 1)); // пауза на старте
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.offset, greaterThan(0));
    expect(controller.offset, lessThan(100));
    await tester.pump(const Duration(seconds: 1)); // 100 px / 100 px/с — доехали
    expect(controller.offset, 100);
    await tester.pump(const Duration(seconds: 1)); // пауза → в начало
    await tester.pump();
    expect(controller.offset, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
