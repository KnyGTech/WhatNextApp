import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:whatnext_flutter_client/application/application_theme.dart';

import '../models/episode.dart';
import '../interfaces/interfaces.dart';

class EpisodesView extends StatefulWidget {
  final int _showId;
  final int _season;

  const EpisodesView(this._showId, this._season, {Key? key}) : super(key: key);

  @override
  State<EpisodesView> createState() => _EpisodesViewState();
}

class _EpisodesViewState extends State<EpisodesView> {
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final DateFormat _dateFormatter = DateFormat('yyyy. MM. dd');
  final List<Episode> _episodes = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _client.getEpisodes(widget._showId, widget._season),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            _episodes.clear();
            _episodes.addAll(snapshot.data as List<Episode>);
            return RefreshIndicator(
                onRefresh: onRefresh, child: _renderListView());
          } else {
            return const Center(child: RefreshProgressIndicator());
          }
        }));
  }

  Widget _renderListView() {
    return ListView.builder(
        itemCount: _episodes.length,
        itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(
                  _episodes[index].episodeName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                    _episodes[index].date != null
                        ? _dateFormatter.format(_episodes[index].date!) + (_episodes[index].date!.isAfter(DateTime.now()) ? ' (${_episodes[index].date!.difference(DateTime.now()).inDays} nap)' : '')
                        : 'Nem ismert',
                    style: _episodes[index].date != null
                        ? (_episodes[index].date!.isAfter(DateTime.now())
                            ? TextStyle(color: ApplicationTheme.appColorBlue)
                            : null)
                        : null),
                leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'S${_episodes[index].season.toString().padLeft(2, '0')}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: ApplicationTheme.appColorBlue)),
                      Text(
                          'E${_episodes[index].episode.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleLarge),
                    ]),
                trailing: IconButton(
                    icon: Icon(_episodes[index].seen
                        ? Icons.check_box_rounded
                        : Icons.square_outlined),
                    onPressed: () async {
                      await _client.markEpisode(_episodes[index]);
                      setState(() {
                        _episodes[index].seen = !_episodes[index].seen;
                      });
                    }),
              ),
            ));
  }

  Future<void> onRefresh() async {
    final episodes =
        await _client.getEpisodes(widget._showId, widget._season, force: true);
    setState(() {
      _episodes.clear();
      _episodes.addAll(episodes);
    });
  }
}
