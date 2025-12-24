import 'package:flutter/cupertino.dart';
import 'package:tvc/models/utils.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/info_schedule.dart';

class GamePriceCard extends StatelessWidget {
  final InfoSchedule info;

  const GamePriceCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Utils.getHeightSize(context, 60),
          child: NeoCard(
            child: Text(
              info.done
                  ? "${info.startTime.hour.toString().padLeft(2, '0')}:${info.startTime.minute.toString().padLeft(2, '0')}---${info.endTime.hour.toString().padLeft(2, '0')}:${info.endTime.minute.toString().padLeft(2, '0')}"
                  : "${info.startTime.hour.toString().padLeft(2, '0')}:${info.startTime.minute.toString().padLeft(2, '0')}---vaxt hələ bitməyib",
              style: AppTextStyles.gameTimeBetween(context),
            ),
          ),
        ),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(
          height: Utils.getHeightSize(context, 80),
          child: NeoCard(
            child: (info.done || info.unlimit)
                ? Text(
                    "${(info.timeLeft / 60).toInt()} saat ${info.timeLeft % 60} dəqiqə oynamısız",
                    style: AppTextStyles.gamePrice(context),
                  )
                : Text(
                    "${(info.timeLeft / 60).toInt()} saat ${info.timeLeft % 60} dəqiqə qalıb",
                    style: AppTextStyles.gamePrice(context),
                  ),
          ),
        ),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(
          height: Utils.getHeightSize(context, 130),
          child: NeoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                info.discountPercent > 0.1
                    ? Text(
                        "${(info.basePrice / 100).toStringAsFixed(2)} azn ${info.discountPercent}% endirim",
                        style: AppTextStyles.gameDiscount(context),
                      )
                    : SizedBox.shrink(),
                Text(
                  "${(info.totalPrice / 100).toInt()} manat ${(info.totalPrice % 100).toInt()} qəpik",
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
