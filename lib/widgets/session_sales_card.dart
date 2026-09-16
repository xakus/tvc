import 'package:flutter/material.dart';
import 'package:tvc/localization/tvc_localization.dart';
import 'package:tvc/models/device_state.dart';
import 'package:tvc/widgets/auto_scroll_list.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/utils.dart';
import '../theme/app_text_styles.dart';

/// Строка заказа для блока сумм.
class OrderLine {
  final String productName;
  final int quantity;
  final int totalQepik;

  const OrderLine(this.productName, this.quantity, this.totalQepik);
}

/// Блок сумм во время игры и в итоге (D-37, R-TVC-11/12): заказанные на стол товары (название × количество =
/// сумма, автопрокрутка при нехватке места), «Товары», «Игра», «Итого», для режима «Деньги» — оплачено/сдача.
/// Все суммы — от pscs, экран ничего не складывает (R-TVC-1). Оформление — карточки текущего стиля.
class SessionSalesCard extends StatelessWidget {
  final List<OrderLine> orders;
  final int salesTotalQepik;
  final int gamePriceQepik;
  final int grandTotalQepik;
  final int? paidQepik;
  final int? changeQepik;
  final String scrollMode;

  const SessionSalesCard({
    super.key,
    required this.orders,
    required this.salesTotalQepik,
    required this.gamePriceQepik,
    required this.grandTotalQepik,
    this.paidQepik,
    this.changeQepik,
    this.scrollMode = 'smooth',
  });

  /// Из текущего сеанса.
  factory SessionSalesCard.ofSession(TableSession s, {String scrollMode = 'smooth'}) =>
      SessionSalesCard(
        orders: s.sales
            .map((x) => OrderLine(x.productName, x.quantity, x.totalQepik))
            .toList(),
        salesTotalQepik: s.salesTotalQepik,
        gamePriceQepik: s.currentPriceQepik,
        grandTotalQepik: s.grandTotalQepik,
        scrollMode: scrollMode,
      );

  /// Из чека завершённого сеанса.
  factory SessionSalesCard.ofReceipt(LastReceipt r, {String scrollMode = 'smooth'}) =>
      SessionSalesCard(
        orders: r.sales
            .map((x) => OrderLine(x.productName, x.quantity, x.totalQepik))
            .toList(),
        salesTotalQepik: r.salesTotalQepik,
        gamePriceQepik: r.finalPriceQepik,
        grandTotalQepik: r.grandTotalQepik,
        paidQepik: r.paidQepik,
        changeQepik: r.changeQepik,
        scrollMode: scrollMode,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = TvcLocalization.of(context);
    final rowHeight = Utils.getHeightSize(context, 48);
    final rowPadding = Utils.getHeightSize(context, 5);

    Widget line(String name, String value) => Container(
      padding: EdgeInsets.symmetric(vertical: rowPadding),
      child: SizedBox(
        height: rowHeight,
        child: ListElement(name: name, number: value),
      ),
    );

    return Column(
      children: [
        // Заголовок — как у соседних карточек
        Container(
          height: Utils.getHeightSize(context, 55),
          width: double.infinity,
          alignment: Alignment.center,
          child: NeoCard(
            child: Text(l10n.get('orders'), style: AppTextStyles.menuTitle(context)),
          ),
        ),
        // Заказанные товары: название × кол-во = сумма; прокрутка, если не помещаются
        Expanded(
          child: AutoScrollList(
            key: ValueKey('orders-${orders.length}'),
            padding: EdgeInsets.symmetric(
              vertical: Utils.getHeightSize(context, 10),
            ),
            itemCount: orders.length,
            itemExtent: rowHeight + rowPadding * 2,
            mode: scrollMode,
            itemBuilder: (context, index) {
              final o = orders[index];
              return line(
                '${o.productName} × ${o.quantity}',
                formatAzn(o.totalQepik),
              );
            },
          ),
        ),
        // Итоги — всегда видны
        line(l10n.get('goods'), formatAzn(salesTotalQepik)),
        line(l10n.get('game'), formatAzn(gamePriceQepik)),
        line(l10n.get('total'), formatAzn(grandTotalQepik)),
        if (paidQepik != null) line(l10n.get('paid'), formatAzn(paidQepik!)),
        if (changeQepik != null) line(l10n.get('change'), formatAzn(changeQepik!)),
      ],
    );
  }
}
