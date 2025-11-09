import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvc/models/sales.dart';
import 'package:tvc/services/service.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/utils.dart';
import '../theme/app_text_styles.dart';

class SalesCard extends StatefulWidget {
  const SalesCard({super.key});

  @override
  State<SalesCard> createState() => _SalesCardState();
}

class _SalesCardState extends State<SalesCard> {
  List<Sales> _sales = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSales();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _loadSales());
  }

  Future<void> _loadSales() async {
    try {
      setState(() {
        Service().getSales().then((value) => _sales = value);
      });
    } catch (e) {
      // можно добавить лог или Snackbar
      debugPrint("Ошибка при загрузке sales: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

          // Список
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: Utils.getHeightSize(context, 10),
              ),
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                final item = _sales[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Utils.getHeightSize(context, 5),
                  ),
                  child: SizedBox(
                    height: Utils.getHeightSize(context, 35),
                    child: ListElement(
                      name: item.product,
                      number: "${item.price.toStringAsFixed(2)} azn",
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
