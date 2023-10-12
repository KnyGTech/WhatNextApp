import 'package:flutter/material.dart';

class ApplicationTheme {
  static Color appColorLighterGrey = const Color.fromARGB(255, 192, 192, 192);
  static Color appColorLightGrey = const Color.fromARGB(255, 136, 136, 136);
  static Color appColorMediumGrey = const Color.fromARGB(255, 65, 65, 65);
  static Color appColorDarkGrey = const Color.fromARGB(255, 40, 40, 40);
  static Color appColorDarkerGrey = const Color.fromARGB(255, 19, 19, 19);
  static Color appColorBlue = const Color.fromARGB(255, 19, 119, 149);

  static Color tabColorGreen = const Color.fromARGB(255, 39, 151, 71);
  static Color tabColorYellow = const Color.fromARGB(255, 169, 182, 64);
  static Color tabColorRed = const Color.fromARGB(255, 126, 36, 38);
  static Color tabColorOrange = const Color.fromARGB(255, 159, 95, 2);
  static Color tabColorBlue = const Color.fromARGB(255, 25, 107, 159);

  static List<Color> tabColors = [
    ApplicationTheme.tabColorGreen,
    ApplicationTheme.tabColorYellow,
    ApplicationTheme.tabColorRed,
    ApplicationTheme.tabColorOrange,
    ApplicationTheme.tabColorBlue
  ];

  static Map<String, int> breakpoints = {
    'sm' : 300,
    'md' : 400,
    'lg' : 700,
  };

  static bool isSmallDevice(BuildContext context) => MediaQuery.of(context).size.width >= breakpoints['sm']!;
  static bool isMediumDevice(BuildContext context) => MediaQuery.of(context).size.width >= breakpoints['md']!;
  static bool isLargeDevice(BuildContext context) => MediaQuery.of(context).size.width >= breakpoints['lg']!;

  static TextStyle errorTextTheme =
      const TextStyle(fontSize: 14, color: Colors.red);

  static ThemeData primaryTheme = ThemeData(
      appBarTheme: AppBarTheme(
          backgroundColor: appColorDarkerGrey,
          foregroundColor: appColorLightGrey),
      indicatorColor: appColorBlue,
      backgroundColor: appColorMediumGrey,
      scaffoldBackgroundColor: appColorMediumGrey,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appColorBlue, foregroundColor: appColorLighterGrey),
      cardColor: appColorDarkGrey,
      primaryColor: appColorLighterGrey,
      primaryTextTheme: TextTheme(
        bodyText1: TextStyle(color: appColorLighterGrey),
      ),
      textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appColorLighterGrey)),
      listTileTheme: ListTileThemeData(
        textColor: appColorLighterGrey,
      ),
      colorScheme: ColorScheme.dark(primary: appColorBlue),
      progressIndicatorTheme: ProgressIndicatorThemeData(
          refreshBackgroundColor: appColorLighterGrey, color: appColorBlue));
}
