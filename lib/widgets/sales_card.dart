import 'package:flutter/material.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import '../models/sales.dart';
import '../models/utils.dart';
import '../theme/app_text_styles.dart';

class SalesCard extends StatelessWidget {
  final List<Sales> items;

  const SalesCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              child: Text("Qiymətlər", style: AppTextStyles.menuTitle(context)),
            ),
          ),

          // Список, занимающий всё оставшееся пространство
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: Utils.getHeightSize(context, 10),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Utils.getHeightSize(context, 5),
                  ),
                  child: SizedBox(
                    height: Utils.getHeightSize(context, 35),
                    child: ListElement(
                      name: items[index].product,
                      number: "${items[index].price.toStringAsFixed(2)} azn",
                    ),
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
