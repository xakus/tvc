import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvc/widgets/list_element.dart';
import 'package:tvc/widgets/neumorphic_card.dart';

import '../models/discount.dart';
import '../models/utils.dart';
import '../services/service.dart';
import '../theme/app_text_styles.dart';

class DiscountCard extends StatefulWidget {
  const DiscountCard({super.key});
  @override
  State<DiscountCard> createState() => _DiscountCardState();
}

class _DiscountCardState extends State<DiscountCard> {
  List<Discount> _discount = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDiscount();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _loadDiscount());
  }

  Future<void> _loadDiscount() async {
    try {
      setState(() {
        Service().getDiscount().then((value) => _discount = value);
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
              child: Text(
                "Endirimlər",
                style: AppTextStyles.menuTitle(context),
              ),
            ),
          ),

          // Список, занимающий всё оставшееся пространство
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: Utils.getHeightSize(context, 10),
              ),
              itemCount: _discount.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Utils.getHeightSize(context, 5),
                  ),
                  child: SizedBox(
                    height: Utils.getHeightSize(context, 35),
                    child: ListElement(
                      name: _discount[index].title,
                      number: "${_discount[index].percent}%",
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
