import 'package:flutter/cupertino.dart';

class Utils {
  static double getHeightSize(BuildContext context, double size) {
    double height = MediaQuery.of(context).size.height;
    const double hConst = 1080;
    double percent = height / hConst;
    return size * percent;
  }
}
