import 'package:flutter/material.dart';

import '../service/service.dart';
import '../views/shows_view.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    final _client = WhatNextClient(
        baseUrl: 'https://whatnext.cc',
        sessionCookie:
            'userid=25337; loginpass=b27eb252d6c7d8584350b2d7c8e778be');

    return FutureBuilder<List<String>>(
        future: _client.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            var _groups = snapshot.data;
            return DefaultTabController(
                length: _groups?.length ?? 0,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('WhatNext Client'),
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: _groups?.map((e) => Tab(text: e)).toList() ?? [],
                      indicatorColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      onTap: (index) {
                        _client.changeGroup(index + 1);
                      },
                    ),
                  ),
                  backgroundColor: Color.fromARGB(255, 65, 65, 65),
                  body: const TabBarView(children: [
                    ShowView(),
                    ShowView(),
                    ShowView(),
                    ShowView(),
                    ShowView(),
                  ]),
                ));
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
