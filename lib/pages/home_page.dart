import 'package:flutter/material.dart';
import 'package:tvc/models/sales.dart';
import 'package:tvc/theme/app_colors.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/clock_widget.dart';
import 'package:tvc/widgets/game_price_card.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import 'package:tvc/widgets/sales_card.dart';
import '../models/discount.dart';
import '../models/utils.dart';
import '../widgets/discount_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Пример данных (в будущем можно заменить данными с сервера)
  final List<Discount> discounts = [
    Discount(title: "Şənbə saat 10:00-18:00", percent: 15),
    Discount(title: "Çərşənbə axşamı saat 09:00-18:00", percent: 10),
    Discount(title: "Cümə butun gun", percent: 5),
    Discount(title: "3 saatdan artiq oynayana", percent: 25),
  ];

  final List<Sales> sales = [
    Sales(product: "Dondurma", price: 2),
    Sales(product: "Pepsi", price: 2.5),
    Sales(product: "Coffee", price: 2.5),
    Sales(product: "Çay", price: 1),
    Sales(product: "Rulet", price: 1),
    Sales(product: "Şokolad", price: 2),
    Sales(product: "Snikers", price: 1.5),
  ];

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
                      height: Utils.getHeightSize(context, 120),
                      width: Utils.getHeightSize(context, 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientBlueLight,
                            AppColors.gradientPurpLight,
                          ],
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(Utils.getHeightSize(context, 10)),
                        ),
                        border: Border.all(
                          width: 2,
                          color: AppColors.gradientPurpLight,
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.gradientPurpLightShadow,blurRadius: 5,blurStyle: BlurStyle.outer,offset: Offset(0, 0))
                        ]
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
                            SizedBox(height: Utils.getHeightSize(context, 123)),
                            Expanded(
                              child: Row(
                                children: [
                                  // Блок со скидками
                                  Expanded(
                                    child: DiscountCard(items: discounts),
                                  ),
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
                                  Expanded(child: SalesCard(items: sales)),
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
