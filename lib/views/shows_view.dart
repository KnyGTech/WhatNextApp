import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/pages/detail_page.dart';
import 'package:whatnext_flutter_client/interfaces/interfaces.dart';
import '../models/show.dart';
import 'image_banner.dart';

class ShowView extends StatefulWidget {
  final int _groupId;

  const ShowView(this._groupId, {Key? key}) : super(key: key);

  @override
  State<ShowView> createState() => _ShowViewState();
}

class _ShowViewState extends State<ShowView> {
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final _shows = <Show>[];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Show>>(
        future: _client.getShows(widget._groupId),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            _shows.clear();
            _shows.addAll(snapshot.data ?? []);
            return RefreshIndicator(
                onRefresh: onRefresh, child: _renderListView());
          } else {
            return const Center(
              child: RefreshProgressIndicator(),
            );
          }
        });
  }

  Widget _renderListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(5.0),
        itemCount: _shows.length,
        itemBuilder: (context, i) => Card(
            elevation: 3,
            margin: const EdgeInsets.all(5.0),
            child: ListTile(
              dense: true,
              leading: ImageBanner(_shows[i].banner),
              title: Text(_shows[i].name,
                  style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text(
                  'Évad: ${_shows[i].seasonActual}/${_shows[i].seasonAll}'),
              onTap: () => _navigateToDetails(_shows[i].id),
            )));
  }

  Future onRefresh() async {
    final shows = await _client.getShows(widget._groupId, force: true);
    setState(() {
      _shows.clear();
      _shows.addAll(shows);
    });
  }

  void _navigateToDetails(int showId) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => DetailPage(showId)));
  }
}
