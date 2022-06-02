import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/index_page.dart';

void main() {
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
