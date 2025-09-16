import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext/_lib.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final List<Group> _groups = [];
  bool _isFabVisible = true;
  Color _indicatorColor = ApplicationTheme.tabColors[0];

  @override
  void initState() {
    super.initState();
    GetIt.I.get<ShowsScrollingEvent>().subscribe((args) => setState(() {
          _isFabVisible = args.direction == ScrollDirection.forward;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
        future: _client.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var groups = snapshot.data as List<Group>;
            _groups.clear();
            _groups.addAll(groups);
            return DefaultTabController(
                length: _groups.length,
                child: Builder(builder: (context) {
                  final controller = DefaultTabController.of(context);
                  controller.addListener(() {
                    setState(() {
                      _indicatorColor = ApplicationTheme.tabColors[controller.index];
                    });
                  });
                  return Scaffold(
                      appBar: AppBar(
                        title:
                            Image.asset('assets/images/logo.png', height: 40),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const ProfilePage()));
                            },
                            icon: const Icon(Icons.person),
                          ),
                          IconButton(
                              onPressed: () async {
                                final tabIndex =
                                    DefaultTabController.of(context).index;
                                final GlobalKey<FormState> formKey =
                                    GlobalKey<FormState>();
                                final newName = TextEditingController(
                                    text: _groups[tabIndex].title);
                                var result = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text("Oldal nevének megadása"),
                                          content: Form(
                                              key: formKey,
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: ApplicationTheme
                                                        .appColorLighterGrey),
                                                decoration:
                                                    const InputDecoration(
                                                        hintText: "Új név"),
                                                controller: newName,
                                                validator: (String? value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? "Adj meg egy nevet!"
                                                        : null,
                                              )),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  if (formKey.currentState!
                                                      .validate()) {
                                                    Navigator.pop(
                                                        context, newName.text);
                                                  }
                                                },
                                                child: const Text('Mentés')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Mégse')),
                                          ],
                                        ));
                                if (result != null) {
                                  await _client.renameGroup(
                                      tabIndex + 1, result);
                                  var newGroups = await _client.getGroups();
                                  setState(() {
                                    _groups.clear();
                                    _groups.addAll(newGroups);
                                  });
                                }
                              },
                              icon: const Icon(
                                  Icons.drive_file_rename_outline_sharp)),
                          IconButton(
                              onPressed: () {
                                _client.logout();
                                setState(() {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              const LoginPage())));
                                });
                              },
                              icon: const Icon(Icons.logout))
                        ],
                        bottom: TabBar(
                          indicatorColor: _indicatorColor,
                          isScrollable: true,
                          tabs: _groups
                              .map((e) =>
                                  Tab(text: e.title.isEmpty ? "#" : e.title))
                              .toList(),
                        ),
                      ),
                      body: TabBarView(
                        children: _groups
                            .map((group) => ShowView(group.index))
                            .toList(),
                      ),
                      floatingActionButton: AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          offset:
                              _isFabVisible ? Offset.zero : const Offset(0, 2),
                          child: FloatingActionButton(
                            onPressed: () async {
                              final tabIndex =
                                  DefaultTabController.of(context).index ?? 1;
                              var result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          24, 24, 24, 0),
                                      buttonPadding: EdgeInsets.zero,
                                      actionsPadding:
                                          const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      title:
                                          const Text("Új sorozat hozzáadása"),
                                      content: SearchPage(tabIndex + 1),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Mégse"))
                                      ],
                                    );
                                  });
                              if (result != null && result) {
                                GetIt.I.get<NewShowAddedEvent>().broadcast(
                                    NewShowAddedEventArgs(tabIndex + 1));
                              }
                            },
                            child: const Icon(Icons.add),
                          )));
                }));
          } else {
            return const Center(child: RefreshProgressIndicator());
          }
        });
  }
}
