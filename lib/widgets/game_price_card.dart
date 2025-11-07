import 'package:flutter/cupertino.dart';
import 'package:tvc/models/utils.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

class GamePriceCard extends StatefulWidget {
  @override
  State<GamePriceCard> createState() => _GamePriceCardState();

}

class _GamePriceCardState extends State<GamePriceCard>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: Utils.getHeightSize(context, 60), child: NeumorphicCard(child: Text("12:44---13:32",style: AppTextStyles.gameTimeBetween(context),))),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(height: Utils.getHeightSize(context, 80), child: NeumorphicCard(child: Text("1 saat 23 dəqiqə oynamısız",style: AppTextStyles.gamePrice(context),))),
        SizedBox(height: Utils.getHeightSize(context, 10)),
        SizedBox(height: Utils.getHeightSize(context, 130), child: NeumorphicCard(child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("4.15azn 15% endirim",style: AppTextStyles.gameDiscount(context),),
              Text("3 manat 53 qəpik",style: AppTextStyles.gameTime(context),),

            ],
          ))),
      ],
    );
  }

}