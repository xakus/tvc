import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  late DateTime _now;

  // Список дней недели на азербайджанском
  final List<String> _weekDaysAZ = [
    "Bazar ertəsi",       // Понедельник
    "Çərşənbə axşamı",   // Вторник
    "Çərşənbə",           // Среда
    "Cümə axşamı",        // Четверг
    "Cümə",               // Пятница
    "Şənbə",              // Суббота
    "Bazar",              // Воскресенье
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // Таймер обновляет время каждую секунду
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString =
        "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";
    final dateString =
        "${_now.day.toString().padLeft(2, '0')}/${_now.month.toString().padLeft(2, '0')}/${_now.year}";
    final weekDayString = _weekDaysAZ[_now.weekday - 1]; // weekday: 1-7

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(dateString, style: AppTextStyles.date(context)),
        Text(timeString, style: AppTextStyles.time(context)),
        Text(weekDayString, style: AppTextStyles.weekName(context)),
      ],
    );
  }
}
