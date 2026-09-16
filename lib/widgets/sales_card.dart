import 'package:flutter/material.dart';
import 'package:tvc/models/device_state.dart';
import 'package:tvc/widgets/auto_scroll_list.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/utils.dart';
import '../theme/app_text_styles.dart';

/// Прайс-лист товаров (`idle.products`, R-TVC-10): в режиме `ALL_PAGED` список прокручивается сам (D-37),
/// в `TOP_N` pscs уже отдал первые N — список неподвижен. Оформление прежнее.
class SalesCard extends StatelessWidget {
  final IdleBlock idle;
  final String scrollMode;

  const SalesCard({super.key, required this.idle, this.scrollMode = 'smooth'});

  @override
  Widget build(BuildContext context) {
    final rowHeight = Utils.getHeightSize(context, 48);
    final rowPadding = Utils.getHeightSize(context, 5);
    final products = idle.products;
    Widget row(BuildContext context, int index) {
      final item = products[index];
      return Container(
        padding: EdgeInsets.symmetric(vertical: rowPadding),
        child: SizedBox(
          height: rowHeight,
          child: ListElement(
            name: item.name,
            number: formatAzn(item.priceQepik),
          ),
        ),
      );
    }

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
              child: Text("Qiymətlər", style: AppTextStyles.menuTitle(context)),
            ),
          ),

          // Список
          Expanded(
            child: idle.autoScroll
                ? AutoScrollList(
                    key: ValueKey('products-${products.length}'),
                    padding: EdgeInsets.symmetric(
                      vertical: Utils.getHeightSize(context, 10),
                    ),
                    itemCount: products.length,
                    itemExtent: rowHeight + rowPadding * 2,
                    mode: scrollMode,
                    stepInterval: Duration(
                      seconds: idle.pageIntervalSec < 1 ? 1 : idle.pageIntervalSec,
                    ),
                    itemBuilder: row,
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: Utils.getHeightSize(context, 10),
                    ),
                    itemCount: products.length,
                    itemBuilder: row,
                  ),
          ),
        ],
      ),
    );
  }
}
