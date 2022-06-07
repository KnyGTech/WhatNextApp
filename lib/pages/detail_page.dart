import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/models/episode.dart';
import 'package:whatnext_flutter_client/service/interface.dart';

import '../models/show.dart';

class DetailPage extends StatefulWidget {
  const DetailPage(this._showId, {Key? key}) : super(key: key);

  final int _showId;

  @override
  State<DetailPage> createState() => _DetailPageState(_showId);
}

class _DetailPageState extends State<DetailPage> {
  _DetailPageState(this._showId);

  final int _showId;
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/images/logo.png', height: 40),
            bottom: const TabBar(isScrollable: true, tabs: [
              Tab(text: 'Season 1'),
              Tab(text: 'Season 2'),
              Tab(text: 'Season 3'),
              Tab(text: 'Season 4')
            ]),
          ),
          body: FutureBuilder(
            future: _client.getShow(_showId),
            builder: ((builder, snapshot) {
              if (snapshot.hasData) {
                var show = snapshot.data as Show;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(child: _renderShow(show)),
                    Expanded(
                        child: TabBarView(children: [
                      _renderEpisodeList(show.episodes),
                      _renderEpisodeList(show.episodes),
                      _renderEpisodeList(show.episodes),
                      _renderEpisodeList(show.episodes)
                    ]))
                  ],
                );
              } else {
                return const RefreshProgressIndicator();
              }
            }),
          ),
        ));
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
      title: Text(show.name, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text('Évad: ${show.seasonActual}/${show.seasonAll}'),
    );
  }

  Widget _renderEpisodeList(List<Episode> episodes) {
    return ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) => Card(
                child: ListTile(
              title: Text(
                episodes[index].episodeName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                  'S${episodes[index].season.toString().padLeft(2, '0')}E${episodes[index].episode.toString().padLeft(2, '0')}'),
              trailing: Icon(episodes[index].seen
                  ? Icons.check_box_rounded
                  : Icons.square_outlined),
            )));
  }
}
