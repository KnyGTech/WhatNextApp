import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../interfaces/interfaces.dart';
import '../pages/index_page.dart';
import '../pages/login_page.dart';
import 'service_configurator.dart';
import 'application_theme.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

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
        theme: ApplicationTheme.primaryTheme,
        home: FutureBuilder(
          future: Future.wait([
            ServiceConfigurator.setup(),
            Future.delayed(const Duration(seconds: 1), () => true)
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final updater = GetIt.I.get<AutoUpdater>();
              if (updater.hasUpdate) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  var result = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Új verzió érhető el'),
                            content: Text(
                                'Szeretné frissíteni a(z) ${updater.latestVersion} verzióra? Az aktuális verzió a(z) ${updater.currentVersion}!',
                                style: TextStyle(
                                    color:
                                        ApplicationTheme.appColorLighterGrey)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Később")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("Kihagyás")),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text("Frissítés",
                                      style: TextStyle(
                                          color: ApplicationTheme
                                              .appColorLighterGrey)))
                            ],
                          ));
                  if (result != null) {
                    if (result) {
                      var permissions = await [
                        Permission.storage,
                        Permission.requestInstallPackages
                      ].request();
                      if (permissions[Permission.storage]!.isGranted) {
                        var downloaded = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text("Frissítés letöltése"),
                                content: SizedBox(
                                  height: 100,
                                  child: FutureBuilder(
                                    future: updater.downloadUpdate(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final result = snapshot.data as String;
                                        if (result.isEmpty) {
                                          return Center(
                                              child: Column(children: [
                                            Text(
                                                "Hiba történt a frissítés letöltése közben!",
                                                style: TextStyle(
                                                    color: ApplicationTheme
                                                        .appColorLighterGrey)),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Bezárás",
                                                    style: TextStyle(
                                                        color: ApplicationTheme
                                                            .appColorLighterGrey)))
                                          ]));
                                        } else {
                                          return Center(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, result);
                                                  },
                                                  child: Text("Telepítés",
                                                      style: TextStyle(
                                                          color: ApplicationTheme
                                                              .appColorLighterGrey))));
                                        }
                                      } else {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                    },
                                  ),
                                )));
                        if (downloaded != null) {
                          if (permissions[Permission.requestInstallPackages]!
                              .isGranted) {
                            OpenFile.open(downloaded);
                          }
                        }
                      }
                    } else {
                      updater.skipVersion(updater.latestVersion);
                    }
                  }
                });
              }

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
