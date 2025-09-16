import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatnext/_lib.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final client = GetIt.I.get<WhatNextClient>();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        body: Center(
            child: SingleChildScrollView(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(height: 25),
            Text(
              'Bejelentkezés',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(error, style: ApplicationTheme.errorTextTheme),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.all(25),
                child: AutofillGroup(
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Felhasználónév'),
                              validator: (String? value) =>
                                  value == null || value.isEmpty
                                      ? "Add meg a felhasználóneved!"
                                      : null,
                              controller: username,
                              autofillHints: const [AutofillHints.username],
                              onChanged: (value) {
                                setState(() {
                                  error = "";
                                });
                              },
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              decoration:
                                  const InputDecoration(hintText: 'Jelszó'),
                              validator: (String? value) =>
                                  value == null || value.isEmpty
                                      ? "Add meg a jelszavad!"
                                      : null,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.password],
                              controller: password,
                              onChanged: (value) {
                                setState(() {
                                  error = "";
                                });
                              },
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50), // NEW
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    var response = await client.login(
                                        username.value.text,
                                        password.value.text);
                                    if (!client.isLoggedIn) {
                                      setState(() {
                                        error = response;
                                        password.clear();
                                      });
                                    } else {
                                      setState(() {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const IndexPage()));
                                      });
                                    }
                                  }
                                },
                                child: Text("Bejelentkezés",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge)),
                            const SizedBox(height: 25),
                            TextButton(
                                onPressed: () async {
                                  final url =
                                      Uri.parse(client.getRegisterLink());
                                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                    if (kDebugMode) {
                                      print('Could not launch $url');
                                    }
                                  }
                                },
                                child: const Text("Regisztráció"))
                          ],
                        ))))
          ],
        ))));
  }
}
