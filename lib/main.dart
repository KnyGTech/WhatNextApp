import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/service/interface.dart';
import 'package:whatnext_flutter_client/service/service.dart';
import 'pages/index_page.dart';

void setup() {
  var client = WhatNextScraperClient(
      baseUrl: 'https://whatnext.cc',
      sessionCookie:
          'userid=25337; loginpass=b27eb252d6c7d8584350b2d7c8e778be');

  GetIt.I.registerSingleton<WhatNextClient>(client);
}

Future<void> main() async {
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 18, 18, 18),
          systemNavigationBarIconBrightness: Brightness.light));
    }

    return MaterialApp(
        title: 'WhatNext Client',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 18, 18, 18),
              foregroundColor: Color.fromARGB(255, 136, 136, 136)),
        ),
        home: const IndexPage());
  }
}
