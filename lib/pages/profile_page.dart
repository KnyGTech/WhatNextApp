import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext/_lib.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _client = GetIt.I.get<WhatNextClient>();
  Profile? _profile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _client.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _profile = snapshot.data as Profile;
            return _renderBody();
          } else {
            return Scaffold(
                appBar: AppBar(
                    title: Image.asset('assets/images/logo.png', height: 40)),
                body: const Center(child: RefreshProgressIndicator()));
          }
        });
  }

  Widget _renderBody() {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Image.asset('assets/images/logo.png', height: 40),
              actions: [
                IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))
              ],
              bottom: const TabBar(isScrollable: true, tabs: [
                Tab(child: Text('Sorozatok')),
                Tab(child: Text('Aktivitás'))
              ]),
            ),
            body: Column(children: [
              _renderProfileCard(),
              Expanded(
                  child: TabBarView(
                      children: [_renderShowsCard(), _renderActivityCard()]))
            ])));
  }

  Widget _renderProfileCard() {
    return Card(
      child: ListTile(
        leading: _profile?.avatar != null
            ? Image.network(_profile!.avatar,
                width: 50,
                loadingBuilder: ((context, child, loadingProgress) =>
                    loadingProgress == null
                        ? child
                        : Image.asset('assets/images/avatar.png')),
                errorBuilder: ((context, error, stackTrace) =>
                    Image.asset('assets/images/avatar.png')))
            : Image.asset('assets/images/avatar.png'),
        title:
            Text(_profile!.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(_profile!.email),
        trailing: Text(_profile!.statistics,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: ApplicationTheme.appColorBlue)),
      ),
    );
  }

  Widget _renderShowsCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Sorozatok",
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('${_profile!.shows.length} db',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              )),
          Expanded(
              child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 2.45, crossAxisCount: 3),
                    itemBuilder: (context, index) =>
                        Card(child: ImageBanner(_profile!.shows[index])),
                    itemCount: _profile!.shows.length,
                  ))),
        ],
      ),
    );
  }

  Widget _renderActivityCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("Utoljára megtekintett epizódok",
                  style: Theme.of(context).textTheme.titleLarge)),
          Expanded(
              child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => ListTile(
                      dense: true,
                      leading: ImageBanner(_profile!.activities[index].banner),
                      title: Text(_profile!.activities[index].show,
                          style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Text(_profile!.activities[index].episode),
                      trailing: Text(_profile!.activities[index].time),
                    ),
                    itemCount: _profile!.activities.length,
                  ))),
        ],
      ),
    );
  }

  Future _refresh() async {
    var newProfile = await _client.getProfile(force: true);
    setState(() {
      _profile = newProfile;
    });
  }
}
