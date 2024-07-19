import 'package:flutter/material.dart';

// MediaQuery constants
class ScreenSize {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Get a height value adjusted by a percentage of the screen height
  static double adjustedHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  // Get a width value adjusted by a percentage of the screen width
  static double adjustedWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }
}

// Pixel constants adjusted to screen size
class AppPadding {
  // 5% of screen height
  static double p5(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 0.5);

  // 1% of screen height
  static double p10(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 1);

  // 2% of screen height
  static double p20(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 2);

  // 3% of screen height
  static double p30(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 3);

  // 4% of screen height
  static double p40(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 4);

  // 5% of screen height
  static double p50(BuildContext context) =>
      ScreenSize.adjustedHeight(context, 5);
}

// App Colors
class AppColors {
  static const backgroundColor = Color.fromRGBO(19, 28, 33, 1);
  static const textColor = Color.fromRGBO(241, 241, 242, 1);
  static const appBarColor = Color.fromRGBO(31, 44, 52, 1);
  static const bottomAttachContainerColor = Color.fromRGBO(38, 54, 65, 1.0);
  static const webAppBarColor = Color.fromRGBO(42, 47, 50, 1);
  static const messageColor = Color.fromARGB(255, 117, 221, 164);
  static const senderMessageColor = Color.fromRGBO(220, 248, 198, 1);
  static const tabColor = Color.fromRGBO(0, 167, 131, 1);
  static const searchBarColor = Color.fromRGBO(50, 55, 57, 1);
  static const dividerColor = Color.fromRGBO(37, 45, 50, 1);
  static const chatBarMessage = Color.fromRGBO(30, 36, 40, 1);
  static const mobileChatBoxColor = Color.fromRGBO(31, 44, 52, 1);
  static const lightGreyColor = Colors.white70;
  static const greyColor = Colors.grey;
  static const blackColor = Colors.black;
  static const whiteColor = Colors.white;
  static const errorRed = Colors.red;
}
