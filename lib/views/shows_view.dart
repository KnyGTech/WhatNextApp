import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext_flutter_client/application/application_theme.dart';
import 'package:whatnext_flutter_client/events/new_show_added_event.dart';
import 'package:whatnext_flutter_client/events/shows_scrolling_event.dart';
import 'package:whatnext_flutter_client/pages/detail_page.dart';
import 'package:whatnext_flutter_client/interfaces/interfaces.dart';
import '../models/models.dart';
import 'image_banner.dart';

class ShowView extends StatefulWidget {
  final int _groupId;

  const ShowView(this._groupId, {Key? key}) : super(key: key);

  @override
  State<ShowView> createState() => _ShowViewState();
}

class _ShowViewState extends State<ShowView> {
  final newShowAddedEvent = GetIt.I.get<NewShowAddedEvent>();
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final _shows = <Show>[];
  ScrollDirection _previousDirection = ScrollDirection.idle;

  @override
  void initState() {
    super.initState();

    newShowAddedEvent.subscribe(handleNewShowAddedEvent);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Show>>(
        future: _client.getShows(widget._groupId),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            _shows.clear();
            _shows.addAll(snapshot.data ?? []);
            return RefreshIndicator(
                onRefresh: refresh, child: _renderListView());
          } else {
            return const Center(
              child: RefreshProgressIndicator(),
            );
          }
        });
  }

  Widget _renderListView() {
    var controller = ScrollController();
    controller.addListener(() {
      var currentDirection = controller.position.userScrollDirection;
      if (_previousDirection != currentDirection) {
        GetIt.I
            .get<ShowsScrollingEvent>()
            .broadcast(ShowsScrollingEventArgs(currentDirection));
        _previousDirection = currentDirection;
      }
    });
    return ReorderableListView.builder(
        scrollController: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 75.0),
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          if (Platform.isAndroid) {
            var card = (((child as ReorderableDelayedDragStartListener).child
                        as MergeSemantics)
                    .child as Semantics)
                .child as Card;
            return Card(
              elevation: 3,
              margin: const EdgeInsets.all(5.0),
              color: ApplicationTheme.appColorBlue,
              clipBehavior: Clip.antiAlias,
              child: card.child,
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: ApplicationTheme.appColorBlue,
            ),
            child: child,
          );
        },
        itemCount: _shows.length,
        onReorder: (int oldIndex, int newIndex) async {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Show item = _shows.removeAt(oldIndex);
          _shows.insert(newIndex, item);
          var indices = _shows.map((item) => item.id).toList();
          await _client.reorder(indices, widget._groupId);
          refresh();
        },
        itemBuilder: (context, i) => Card(
            key: ValueKey(_shows[i].id.toString()),
            elevation: 3,
            margin: const EdgeInsets.all(5.0),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
                dense: true,
                leading: ImageBanner(_shows[i].banner),
                title: Text(_shows[i].name,
                    style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text(
                    'Évad: ${_shows[i].seasonActual}/${_shows[i].seasonAll}'),
                onTap: () => _navigateToDetails(_shows[i].id),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  _shows[i].indicator == null
                      ? const Icon(null)
                      : _shows[i].indicator!
                          ? const Icon(Icons.check_circle_outline)
                          : Icon(Icons.more_time,
                              color: ApplicationTheme.appColorBlue),
                  PopupMenuButton(
                      icon: Icon(Icons.more_vert,
                          color: ApplicationTheme.appColorLighterGrey),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Törlés',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              onTap: () async {
                                await _client.removeShow(_shows[i].id);
                                refresh();
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Áthelyezés',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              onTap: () async {
                                var groups = (await _client.getGroups()).where(
                                    (Group group) =>
                                        group.index != widget._groupId);

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) async {
                                  var result = await showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                            title: const Text(
                                                "Áthelyezés másik lapra"),
                                            children: groups
                                                .map((group) =>
                                                    SimpleDialogOption(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0,
                                                          horizontal: 24.0),
                                                      onPressed: () {
                                                        Navigator.pop(context,
                                                            group.index);
                                                      },
                                                      child: Text(group.title,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleLarge!
                                                              .copyWith(
                                                                  color: ApplicationTheme
                                                                      .appColorBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                    ))
                                                .toList(),
                                          ));
                                  await _client.move(_shows[i].id, result);
                                  refresh();
                                });
                              },
                            )
                          ])
                ]))));
  }

  Future refresh() async {
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

  void handleNewShowAddedEvent(NewShowAddedEventArgs? args) {
    if (!mounted) return;
    if (args != null && args.groupId == widget._groupId) {
      refresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    newShowAddedEvent.unsubscribe(handleNewShowAddedEvent);
  }
}
