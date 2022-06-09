import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatnext_flutter_client/pages/login_page.dart';
import 'package:whatnext_flutter_client/service/interface.dart';
import 'package:whatnext_flutter_client/service/service.dart';

Future<void> setup() async {

  var prefs = await SharedPreferences.getInstance();
  var client = WhatNextScraperClient(baseUrl: 'https://whatnext.cc');

  GetIt.I.registerSingleton<WhatNextClient>(client);
  GetIt.I.registerSingleton<SharedPreferences>(prefs);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 18, 18, 18),
          systemNavigationBarIconBrightness: Brightness.light));
    }

    return MaterialApp(
        title: 'WhatNext Client',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 18, 18, 18),
                foregroundColor: Color.fromARGB(255, 136, 136, 136)),
            indicatorColor: const Color.fromARGB(255, 19, 119, 149),
            backgroundColor: const Color.fromARGB(255, 65, 65, 65),
            scaffoldBackgroundColor: const Color.fromARGB(255, 65, 65, 65),
            cardColor: const Color.fromARGB(255, 40, 40, 40),
            primaryColor: const Color.fromARGB(255, 192, 192, 192),
            primaryTextTheme: const TextTheme(
              bodyText1: TextStyle(color: Color.fromARGB(255, 192, 192, 192)),
            ),
            textTheme: const TextTheme(
                titleLarge: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 192, 192, 192))),
            listTileTheme: const ListTileThemeData(
              textColor: Color.fromARGB(255, 192, 192, 192),
            ),
            colorScheme: const ColorScheme.dark(
                primary: Color.fromARGB(255, 19, 119, 149)),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
                refreshBackgroundColor: Color.fromARGB(255, 192, 192, 192),
                color: Color.fromARGB(255, 19, 119, 149))),
        home: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 1), () => true),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const LoginPage();
            }
            return Scaffold(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                body: Center(
                  child: Image.asset('assets/images/logo.png'),
                ));
          },
        ));
  }
}
