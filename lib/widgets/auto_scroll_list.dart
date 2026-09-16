import 'dart:async';

import 'package:flutter/material.dart';

/// Список, который прокручивается сам, если не помещается (D-37, R-TVC-10/11): дойдя до конца — пауза и
/// возврат в начало. Два способа (T-24, `productsScroll` в config.json): `smooth` — одна линейная анимация на
/// весь список со скоростью [pixelsPerSecond]; `step` — сдвиг на строку каждые [stepInterval] без анимации
/// (минимальная нагрузка на CPU Orange Pi). Если всё помещается — обычный неподвижный список.
class AutoScrollList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Высота одной строки (включая отступы) — шаг для режима `step`.
  final double itemExtent;
  final EdgeInsetsGeometry padding;
  final String mode; // smooth | step
  final double pixelsPerSecond;
  final Duration stepInterval;
  final Duration pauseAtEdges;

  const AutoScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemExtent,
    this.padding = EdgeInsets.zero,
    this.mode = 'smooth',
    this.pixelsPerSecond = 24,
    this.stepInterval = const Duration(seconds: 3),
    this.pauseAtEdges = const Duration(seconds: 3),
  });

  @override
  State<AutoScrollList> createState() => _AutoScrollListState();
}

class _AutoScrollListState extends State<AutoScrollList> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(AutoScrollList old) {
    super.didUpdateWidget(old);
    if (old.itemCount != widget.itemCount ||
        old.mode != widget.mode ||
        old.itemExtent != widget.itemExtent) {
      _restart();
    }
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restart() {
    _generation++;
    _timer?.cancel();
    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }
    _schedule();
  }

  /// Первый запуск после раскладки: узнаём, есть ли что прокручивать.
  void _schedule() {
    final gen = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || gen != _generation) {
        return;
      }
      if (!_overflows) {
        return;
      }
      if (widget.mode == 'step') {
        _timer = Timer.periodic(widget.stepInterval, (_) => _step());
      } else {
        _timer = Timer(widget.pauseAtEdges, () => _smoothLoop(gen));
      }
    });
  }

  bool get _overflows =>
      _controller.hasClients && _controller.position.maxScrollExtent > 1;

  /// Пошагово: строка за строкой, в конце — в начало.
  void _step() {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final max = _controller.position.maxScrollExtent;
    final next = _controller.offset + widget.itemExtent;
    if (_controller.offset >= max - 1) {
      _controller.jumpTo(0);
    } else {
      _controller.jumpTo(next > max ? max : next);
    }
  }

  /// Плавно: до конца линейно, пауза, в начало, пауза, снова. Паузы — отменяемые таймеры (dispose).
  Future<void> _smoothLoop(int gen) async {
    if (!mounted || gen != _generation || !_controller.hasClients) {
      return;
    }
    final max = _controller.position.maxScrollExtent;
    if (max <= 1) {
      return;
    }
    final distance = max - _controller.offset;
    final ms = (distance / widget.pixelsPerSecond * 1000).round();
    await _controller.animateTo(
      max,
      duration: Duration(milliseconds: ms < 200 ? 200 : ms),
      curve: Curves.linear,
    );
    if (!mounted || gen != _generation) {
      return;
    }
    _timer = Timer(widget.pauseAtEdges, () {
      if (!mounted || gen != _generation || !_controller.hasClients) {
        return;
      }
      _controller.jumpTo(0);
      _timer = Timer(widget.pauseAtEdges, () => _smoothLoop(gen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemExtent: widget.itemExtent,
      itemBuilder: widget.itemBuilder,
    );
  }
}
