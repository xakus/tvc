import 'package:flutter/material.dart';
import 'package:tvc/theme/app_colors.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/clock_widget.dart';
import 'package:tvc/widgets/game_price_card.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import 'package:tvc/widgets/sales_card.dart';

import '../models/utils.dart';
import '../widgets/discount_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Пример данных (в будущем можно заменить данными с сервера)
  String tableName = "PS3 Stol1";
  String pricePerHour = "1 saat - 3 azn";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        // ← растягивает фон на весь экран
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(40),
                    child: Container(
                      height: Utils.getHeightSize(context, 80),
                      width: Utils.getHeightSize(context, 250),
                      decoration: BoxDecoration(
                        color: AppColors.gradientBlueLight,
                        borderRadius: BorderRadius.all(
                          Radius.circular(Utils.getHeightSize(context, 10)),
                        ),
                        border: Border.all(width: 2, color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientBlueLightShadow,
                            blurRadius: 5,
                            blurStyle: BlurStyle.outer,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClockWidget(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: Utils.getHeightSize(context, 100),
                              child: NeumorphicCard(
                                child: Text(
                                  tableName,
                                  style: AppTextStyles.title(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.33,
                              height: Utils.getHeightSize(context, 50),
                              child: NeumorphicCard(
                                child: Text(
                                  pricePerHour,
                                  style: AppTextStyles.subtitle(context),
                                ),
                              ),
                            ),
                            SizedBox(height: Utils.getHeightSize(context, 20)),
                            Expanded(
                              child: Row(
                                children: [
                                  // Блок со скидками
                                  Expanded(child: DiscountCard()),
                                  const SizedBox(width: 40),

                                  // Средний блок (например, цена за час)
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          flex: 0,
                                          child: GamePriceCard(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 40),

                                  // Блок с продажами
                                  Expanded(child: SalesCard()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
