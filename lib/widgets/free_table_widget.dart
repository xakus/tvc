import 'package:flutter/material.dart';
import 'package:tvc/theme/app_colors.dart';

import '../localization/tvc_localization.dart';
import '../models/utils.dart';

/// Отображается когда стол свободен (state == 'idle').
/// Большой зелёный текст с пульсирующей анимацией.
class FreeTableWidget extends StatefulWidget {
  const FreeTableWidget({super.key});

  @override
  State<FreeTableWidget> createState() => _FreeTableWidgetState();
}

class _FreeTableWidgetState extends State<FreeTableWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = TvcLocalization.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Иконка джойстика
          FadeTransition(
            opacity: _pulseAnim,
            child: Icon(
              Icons.sports_esports,
              color: AppColors.green,
              size: Utils.getHeightSize(context, 80),
            ),
          ),
          SizedBox(height: Utils.getHeightSize(context, 16)),

          // Текст "СВОБОДНО" — пульсирует
          FadeTransition(
            opacity: _pulseAnim,
            child: Text(
              l10n.get('free'),
              style: TextStyle(
                color: AppColors.green,
                fontSize: Utils.getHeightSize(context, 90),
                fontFamily: 'Tektur',
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          SizedBox(height: Utils.getHeightSize(context, 20)),

          // Подпись
          Text(
            l10n.get('free_subtitle'),
            style: TextStyle(
              color: Colors.white54,
              fontSize: Utils.getHeightSize(context, 28),
              fontFamily: 'AlumniSans',
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
