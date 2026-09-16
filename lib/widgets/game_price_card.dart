import 'package:flutter/cupertino.dart';
import 'package:tvc/models/utils.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/device_state.dart';

/// Карточки времени и цены игры (R-TVC-11/12) в прежнем оформлении: начало—конец, сколько осталось/сыграли,
/// цена со скидкой. Минуты интерполируются от `serverTime` (R-TVC-1); суммы — только от pscs.
class GamePriceCard extends StatelessWidget {
  final DeviceState state;

  const GamePriceCard({super.key, required this.state});

  static String _hhmm(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  /// Минуты игры/остатка по интерполяции от времени сервера.
  static ({bool done, int minutes}) minutes(DeviceState state) {
    final s = state.session;
    if (s != null) {
      final now = state.serverNow;
      if (s.plannedEndAt != null) {
        final left = s.plannedEndAt!.difference(now).inSeconds;
        return (done: false, minutes: left <= 0 ? 0 : (left + 59) ~/ 60);
      }
      final played = now.difference(s.startedAt).inMinutes;
      return (done: true, minutes: played < 0 ? 0 : played);
    }
    final r = state.lastReceipt;
    return (done: true, minutes: r?.playedMinutes ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = state.session;
    final r = state.lastReceipt;
    final DateTime start = s?.startedAt.toLocal() ?? r?.startedAt.toLocal() ?? DateTime.now();
    final DateTime? end = s != null ? s.plannedEndAt?.toLocal() : r?.stoppedAt.toLocal();
    final m = minutes(state);
    final int basePrice = s?.basePriceQepik ?? r?.basePriceQepik ?? 0;
    final int percent = s?.discountPercent ?? r?.totalPercent ?? 0;
    final int total = s?.currentPriceQepik ?? r?.finalPriceQepik ?? 0;
    final String suffix = m.done ? 'oynamısız' : 'qalıb';
    final String minutesText = m.minutes > 60
        ? "${(m.minutes / 60).toInt()} saat ${m.minutes % 60} dəqiqə $suffix"
        : "${m.minutes % 60} dəqiqə $suffix";

    return Column(
      children: [
        SizedBox(
          height: Utils.getHeightSize(context, 60),
          child: NeoCard(
            child: Text(
              end != null
                  ? "${_hhmm(start)}---${_hhmm(end)}"
                  : "${_hhmm(start)}---vaxt hələ bitməyib",
              style: AppTextStyles.gameTimeBetween(context),
            ),
          ),
        ),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(
          height: Utils.getHeightSize(context, 80),
          child: NeoCard(
            child: Text(minutesText, style: AppTextStyles.gamePrice(context)),
          ),
        ),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(
          height: Utils.getHeightSize(context, 130),
          child: NeoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                percent > 0
                    ? Text(
                        "${(basePrice / 100).toStringAsFixed(2)} azn $percent% endirim",
                        style: AppTextStyles.gameDiscount(context),
                      )
                    : const SizedBox.shrink(),
                Text(
                  total >= 100
                      ? "${total ~/ 100} manat ${total % 100} qəpik"
                      : "${total % 100} qəpik",
                  style: AppTextStyles.gameTime(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
