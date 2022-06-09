import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/interfaces/whatnext_client.dart';

import '../models/show.dart';
import '../views/episodes_view.dart';

class DetailPage extends StatefulWidget {
  const DetailPage(this._showId, {Key? key}) : super(key: key);

  final int _showId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _client.getShow(widget._showId),
      builder: ((builder, snapshot) {
        if (snapshot.hasData) {
          var show = snapshot.data as Show;
          return DefaultTabController(
              length: show.seasonAll,
              initialIndex: show.seasonActual - 1,
              child: Scaffold(
                appBar: AppBar(
                  title: Image.asset('assets/images/logo.png', height: 40),
                  bottom: TabBar(isScrollable: true,
                      tabs: List<Tab>.generate(show.seasonAll, (index) =>
                          Tab(text: '${index + 1}. évad'))),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(child: _renderShow(show)),
                    Expanded(
                        child: TabBarView(children: List<Widget>.generate(
                            show.seasonAll, (index) =>
                            EpisodesView(show.id, index + 1))))
                  ],
                ),
              ));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Image.asset('assets/images/logo.png', height: 40),
            ),
            body: const Center(child: RefreshProgressIndicator()),
          );
        }
      }),
    );
  }

  Widget _renderShow(Show show) {
    return ListTile(
      dense: true,
      leading: Image.network(show.banner,
          width: 130,
          loadingBuilder: ((context, child, loadingProgress) =>
          loadingProgress == null
              ? child
              : Image.asset('assets/images/ikon_placeholder.png')),
          errorBuilder: ((context, error, stackTrace) =>
              Image.asset('assets/images/ikon_placeholder.png'))),
      title: Text(show.name, style: Theme
          .of(context)
          .textTheme
          .titleLarge),
      subtitle: Text('Évad: ${show.seasonActual}/${show.seasonAll}'),
    );
  }
}
