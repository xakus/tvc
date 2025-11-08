import 'package:flutter/cupertino.dart';
import 'package:tvc/models/utils.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

class ListElement extends StatelessWidget {
  final String name;
  final String number;
  final double height;
  final double padding;
  final double? numWidth;

  const ListElement({
    super.key,
    required this.name,
    required this.number,
    this.height = 40,
    this.padding = 20,
    this.numWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Utils.getHeightSize(context, height),
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: NeumorphicCard(
              center: false,
              child: Text(name, style: AppTextStyles.menuName(context)),
            ),
          ),
          SizedBox(width: Utils.getHeightSize(context, padding)),
          Expanded(
            flex: 13,
            child: NeumorphicCard(
              child: Text(number, style: AppTextStyles.menuPercent(context)),
            ),
          ),
        ],
      ),
    );
  }
}
