import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/service/interface.dart';

import '../models/models.dart';
import '../views/shows_view.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final WhatNextClient client = GetIt.I.get<WhatNextClient>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
        future: client.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var groups = snapshot.data;
            return DefaultTabController(
                length: groups?.length ?? 0,
                child: Scaffold(
                  appBar: AppBar(
                    title: Image.asset('assets/images/logo.png', height: 40),
                    bottom: TabBar(
                      isScrollable: true,
                      tabs:
                          groups?.map((e) => Tab(text: e.title)).toList() ?? [],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      ShowView(1),
                      ShowView(2),
                      ShowView(3),
                      ShowView(4),
                      ShowView(5),
                    ],
                  ),
                ));
          } else {
            return Center(
                child: Image.asset('assets/images/logo.png'));
          }
        });
  }
}
