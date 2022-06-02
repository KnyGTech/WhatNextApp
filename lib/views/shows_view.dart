import 'package:flutter/material.dart';
import 'package:whatnext_flutter_client/service/service.dart';

import '../models/show.dart';

class ShowView extends StatefulWidget {
  const ShowView({Key? key}) : super(key: key);

  @override
  State<ShowView> createState() => _ShowViewState();
}

class _ShowViewState extends State<ShowView> {
  final _client = WhatNextClient(
      baseUrl: 'https://whatnext.cc',
      sessionCookie:
          'userid=25337; loginpass=b27eb252d6c7d8584350b2d7c8e778be');
  final _shows = <Show>[];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Show>>(
        future: _client.getShows(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            _shows.clear();
            _shows.addAll(snapshot.data ?? []);
            return ListView.builder(
                padding: const EdgeInsets.all(5.0),
                itemCount: _shows.length,
                itemBuilder: (context, i) => Card(
                    color: Color.fromARGB(255, 40, 40, 40),
                    elevation: 3,
                    margin: const EdgeInsets.all(5.0),
                    child: ListTile(
                      dense: true,
                      textColor: Color.fromARGB(255, 192, 192, 192),
                      leading: Image.network(_shows[i].banner),
                      title: Text(
                        _shows[i].name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Évad: ${_shows[i].seasonActual}/${_shows[i].seasonAll}'),
                    )));
          } else {
            return const Center(
                child: Text(
              'Betöltés...',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ));
          }
        });
  }
}
