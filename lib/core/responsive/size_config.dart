import 'package:flutter/widgets.dart';

class SizeConfig {
  static double screenWidth = 390; // Default logical width before init
  static double screenHeight = 844;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }

  static double relativeWidth(double percentage) =>
      screenWidth * percentage / 100;
  static double relativeHeight(double percentage) =>
      screenHeight * percentage / 100;

  static double relativeSize(double sizeInPixels) {
    return (sizeInPixels / 390.0) * screenWidth;
  }
}
