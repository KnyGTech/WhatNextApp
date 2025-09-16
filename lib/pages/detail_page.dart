import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext/_lib.dart';

class DetailPage extends StatefulWidget {
  const DetailPage(this._showId, {super.key});

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
                  bottom: TabBar(isScrollable: true, tabs: List<Tab>.generate(show.seasonAll, (index) => Tab(text: '${index + 1}. évad'))),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(child: _renderShow(show)),
                    Expanded(child: TabBarView(children: List<Widget>.generate(show.seasonAll, (index) => EpisodesView(show.id, index + 1))))
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
    if (ApplicationTheme.isSmallDevice(context)) {
      return ListTile(
        isThreeLine: false,
        leading: ImageBanner(show.banner, size: ApplicationTheme.isMediumDevice(context) ? null : 65),
        title: Text(show.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(
            '${show.genre?.isEmpty == false ? show.genre : 'Stílus nem ismert'} \n${show.statistics?.isEmpty == false ? show.statistics : 'Statisztika nem ismert'} \n${show.status?.isEmpty == false ? show.status : 'Státusz nem ismert'}'),
      );
    } else {
      return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageBanner(
                show.banner,
              ),
              const SizedBox(height: 10),
              Text(show.name, style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${show.genre?.isEmpty == false ? show.genre : 'Stílus nem ismert'} \n${show.statistics?.isEmpty == false ? show.statistics : 'Statisztika nem ismert'} \n${show.status?.isEmpty == false ? show.status : 'Státusz nem ismert'}',
                style: TextStyle(color: ApplicationTheme.appColorLighterGrey),
              )
            ],
          ));
    }
  }
}
