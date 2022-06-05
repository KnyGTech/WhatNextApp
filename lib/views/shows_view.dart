import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/service/interface.dart';
import '../models/show.dart';

class ShowView extends StatefulWidget {
  final int groupId;

  const ShowView(this.groupId, {Key? key}) : super(key: key);

  @override
  State<ShowView> createState() => _ShowViewState(groupId);
}

class _ShowViewState extends State<ShowView> {
  _ShowViewState(this._groupId);

  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final int _groupId;
  final _shows = <Show>[];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Show>>(
        future: _client.getShows(_groupId),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            _shows.clear();
            _shows.addAll(snapshot.data ?? []);
            return ListView.builder(
                padding: const EdgeInsets.all(5.0),
                itemCount: _shows.length,
                itemBuilder: (context, i) => Card(
                    color: const Color.fromARGB(255, 40, 40, 40),
                    elevation: 3,
                    margin: const EdgeInsets.all(5.0),
                    child: ListTile(
                      dense: true,
                      textColor: const Color.fromARGB(255, 192, 192, 192),
                      leading: Image.network(_shows[i].banner,
                          errorBuilder: ((context, error, stackTrace) =>
                              Image.asset(
                                  'assets/images/ikon_placeholder.png'))),
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
