import 'package:flutter/material.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import '../models/discount.dart';
import '../models/utils.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class DiscountCard extends StatelessWidget {
   final List<Discount> items;

  const DiscountCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Верхний блок — заголовок
          Container(
            height: Utils.getHeightSize(context, 55),
            width: double.infinity,
            alignment: Alignment.center,
            child: NeumorphicCard(
              child: Text(
                "Endirimlər",
                style: AppTextStyles.menuTitle(context),
              ),
            ),
          ),

          // Список, занимающий всё оставшееся пространство
          Expanded(
            child: ListView.builder(
              padding:  EdgeInsets.symmetric(vertical: Utils.getHeightSize(context, 10)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  padding:  EdgeInsets.symmetric(vertical: Utils.getHeightSize(context, 5)),
                  child: SizedBox(
                    height: Utils.getHeightSize(context, 40),
                    child: ListElement(name: items[index].title, number: "${items[index].percent}%",)
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
