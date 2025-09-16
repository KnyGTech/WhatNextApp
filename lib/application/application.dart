import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext/_lib.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Color.fromARGB(255, 18, 18, 18), systemNavigationBarIconBrightness: Brightness.light));
    }

    return MaterialApp(
        title: 'WhatNext Client',
        debugShowCheckedModeBanner: false,
        theme: ApplicationTheme.primaryTheme,
        home: FutureBuilder(
          future: Future.wait([ServiceConfigurator.setup(), Future.delayed(const Duration(seconds: 1), () => true)]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final client = GetIt.I.get<WhatNextClient>();
              if (client.isLoggedIn) {
                return const IndexPage();
              } else {
                return const LoginPage();
              }
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
