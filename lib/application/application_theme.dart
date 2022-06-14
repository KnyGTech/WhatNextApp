import 'package:flutter/material.dart';

class ApplicationTheme {
  static Color appColorLighterGray = const Color.fromARGB(255, 192, 192, 192);
  static Color appColorLightGrey = const Color.fromARGB(255, 136, 136, 136);
  static Color appColorMediumGrey = const Color.fromARGB(255, 65, 65, 65);
  static Color appColorDarkGray = const Color.fromARGB(255, 40, 40, 40);
  static Color appColorDarkerGray = const Color.fromARGB(255, 19, 19, 19);
  static Color appColorBlue = const Color.fromARGB(255, 19, 119, 149);

  static TextStyle errorTextTheme =
      const TextStyle(fontSize: 14, color: Colors.red);

  static ThemeData primaryTheme = ThemeData(
      appBarTheme: AppBarTheme(
          backgroundColor: appColorDarkerGray,
          foregroundColor: appColorLightGrey),
      indicatorColor: appColorBlue,
      backgroundColor: appColorMediumGrey,
      scaffoldBackgroundColor: appColorMediumGrey,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appColorBlue, foregroundColor: appColorLighterGray),
      cardColor: appColorDarkGray,
      primaryColor: appColorLighterGray,
      primaryTextTheme: TextTheme(
        bodyText1: TextStyle(color: appColorLighterGray),
      ),
      textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appColorLighterGray)),
      listTileTheme: ListTileThemeData(
        textColor: appColorLighterGray,
      ),
      colorScheme: ColorScheme.dark(primary: appColorBlue),
      progressIndicatorTheme: ProgressIndicatorThemeData(
          refreshBackgroundColor: appColorLighterGray, color: appColorBlue));
}
