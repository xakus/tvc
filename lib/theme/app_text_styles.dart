import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static double _getFontSize(BuildContext context, double size) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double s = height<width ? height : width;
    const double hConst = 1080;
    double percent = s / hConst;
    return size * percent;
  }

  static TextStyle title(BuildContext context) => TextStyle(
    color: Color.fromARGB(255, 200, 255, 255),
    fontSize: _getFontSize(context, 100),
    fontFamily: 'Tektur',
    fontWeight: FontWeight.w700,
    height: 1,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    color: AppColors.blue,
    fontSize: _getFontSize(context, 50),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.bold,
    height: 1,
  );

  static TextStyle menuTitle(BuildContext context) => TextStyle(
    color: AppColors.green,
    fontSize: _getFontSize(context, 60),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w900,
    height: 0.1,
  );

  static TextStyle menuName(BuildContext context) => TextStyle(
    color: Colors.white,
    fontSize: _getFontSize(context, 25),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w600,
    height: 0.1,
  );
  static TextStyle menuPercent(BuildContext context) => TextStyle(
    color: Colors.white,
    fontSize: _getFontSize(context, 25),
    fontFamily: "AlumniSans",
    fontWeight: FontWeight.w800,
    height: 1,
  );
  static TextStyle menuPrice(BuildContext context) => TextStyle(
    color: AppColors.blue,
    fontSize: _getFontSize(context, 25),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w800,
    height: 1,
  );

  static TextStyle gameTimeBetween(BuildContext context) => TextStyle(
    color: AppColors.blue,
    fontSize: _getFontSize(context, 40),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.bold,
    height: 1,
  );
  static TextStyle gameTime(BuildContext context) => TextStyle(
    color: AppColors.green,
    fontSize: _getFontSize(context, 70),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w900,
    height: 0.9,
  );
  static TextStyle gamePrice(BuildContext context) => TextStyle(
    color: AppColors.green,
    fontSize: _getFontSize(context, 50),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w900,
    height: 1,
  );
  static TextStyle gameDiscount(BuildContext context) => TextStyle(
    color: AppColors.green,
    fontSize: _getFontSize(context, 40),
    fontFamily: 'AlumniSans',
    fontWeight: FontWeight.w300,
    height: .9,
  );
}
