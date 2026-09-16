import 'package:flutter/material.dart';
import 'package:tvc/widgets/auto_scroll_list.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/device_state.dart';
import '../models/utils.dart';
import '../theme/app_text_styles.dart';

/// Скидки клуба (`idle.discounts`, R-TVC-10): название и процент; при нехватке места — автопрокрутка.
class DiscountCard extends StatelessWidget {
  final List<IdleDiscount> discounts;
  final String scrollMode;

  const DiscountCard({
    super.key,
    required this.discounts,
    this.scrollMode = 'smooth',
  });

  @override
  Widget build(BuildContext context) {
    final rowHeight = Utils.getHeightSize(context, 48);
    final rowPadding = Utils.getHeightSize(context, 5);
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
            child: NeoCard(
              child: Text(
                "Endirimlər",
                style: AppTextStyles.menuTitle(context),
              ),
            ),
          ),

          // Список, занимающий всё оставшееся пространство
          Expanded(
            child: AutoScrollList(
              key: ValueKey('discounts-${discounts.length}'),
              padding: EdgeInsets.symmetric(
                vertical: Utils.getHeightSize(context, 10),
              ),
              itemCount: discounts.length,
              itemExtent: rowHeight + rowPadding * 2,
              mode: scrollMode,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: rowPadding),
                  child: SizedBox(
                    height: rowHeight,
                    child: ListElement(
                      name: discounts[index].name,
                      number: "${discounts[index].percent}%",
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
