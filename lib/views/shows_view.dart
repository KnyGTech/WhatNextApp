import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:whatnext/_lib.dart';

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
            return RefreshIndicator(onRefresh: refresh, child: renderListView());
          } else {
            return const Center(
              child: RefreshProgressIndicator(),
            );
          }
        });
  }

  Widget renderListView() {
    var controller = ScrollController();

    controller.addListener(() {
      var currentDirection = controller.position.userScrollDirection;
      if (_previousDirection != currentDirection) {
        GetIt.I.get<ShowsScrollingEvent>().broadcast(ShowsScrollingEventArgs(currentDirection));
        _previousDirection = currentDirection;
      }
    });

    return ReorderableListView.builder(
        scrollController: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 75.0),
        proxyDecorator: getProxyDecorator,
        itemCount: _shows.length,
        onReorder: onReorder,
        itemBuilder: (context, i) => listViewItemBuilder(context, _shows[i]));
  }

  Widget getProxyDecorator(Widget child, int index, Animation<double> animation) {
    if (Platform.isAndroid) {
      var card = (((child as ReorderableDelayedDragStartListener).child as MergeSemantics).child as Semantics).child as Card;
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
  }

  void onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Show item = _shows.removeAt(oldIndex);
    _shows.insert(newIndex, item);
    var indices = _shows.map((item) => item.id).toList();
    await _client.reorder(indices, widget._groupId);
    refresh();
  }

  Widget listViewItemBuilder(BuildContext context, Show show) {
    return Card(
        key: ValueKey(show.id.toString()),
        elevation: 3,
        margin: const EdgeInsets.all(5.0),
        clipBehavior: Clip.antiAlias,
        child: getListTile(context, show));
  }

  Widget getListTile(BuildContext context, Show show) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return ListTile(
            dense: true,
            leading: ImageBanner(show.banner),
            title: Text(show.name, style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text('Évad: ${show.seasonActual}/${show.seasonAll}'),
            onTap: () => navigateToDetails(show.id),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [getShowIndicator(context, show), getListTilePopupActions(context, show)]));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: ListTile(
                  dense: true,
                  leading: ImageBanner(show.banner),
                  title: Text(show.name, style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Text('Évad: ${show.seasonActual}/${show.seasonAll}'),
                  onTap: () => navigateToDetails(show.id),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [getShowIndicator(context, show), getListTilePopupActions(context, show)]))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(width: 1, color: Colors.white38), borderRadius: const BorderRadius.all(Radius.circular(3))),
                  width: 25,
                  height: 25,
                  child: IconButton(
                      onPressed: show.seasonActual > 1
                          ? () async {
                              await _client.getEpisodes(show.id, show.seasonActual - 1, force: true);
                              refresh();
                            }
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_up),
                      constraints: const BoxConstraints(maxWidth: 25, maxHeight: 25),
                      padding: EdgeInsets.zero)),
              const SizedBox(height: 5),
              Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(width: 1, color: Colors.white38), borderRadius: const BorderRadius.all(Radius.circular(3))),
                  width: 25,
                  height: 25,
                  child: IconButton(
                      onPressed: show.seasonActual < show.seasonAll
                          ? () async {
                              await _client.getEpisodes(show.id, show.seasonActual + 1, force: true);
                              refresh();
                            }
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      constraints: const BoxConstraints(maxWidth: 25, maxHeight: 25),
                      padding: EdgeInsets.zero))
            ],
          ),
          getShowEpisodeList(context, show)
        ],
      );
    });
  }

  Widget getShowIndicator(BuildContext context, Show show) {
    return show.indicator == null
        ? const Icon(null)
        : show.indicator!
            ? const Icon(Icons.check_circle_outline)
            : Icon(Icons.more_time, color: ApplicationTheme.appColorBlue);
  }

  Widget getShowEpisodeList(BuildContext context, Show show) {
    return FutureBuilder(
        future: _client.getEpisodes(show.id, show.seasonActual),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var episodes = snapshot.data as List<Episode>;
            var controller = ScrollController();

            return Expanded(
                child: Container(
                    margin: Platform.isAndroid ? const EdgeInsets.fromLTRB(0, 5, 10, 5) : const EdgeInsets.fromLTRB(0, 5, 35, 5),
                    constraints: const BoxConstraints(maxHeight: 55),
                    child: Scrollbar(
                      thickness: Platform.isAndroid ? 0 : null,
                      controller: controller,
                        child: ListView.builder(
                          controller: controller,
                      scrollDirection: Axis.horizontal,
                      itemCount: episodes.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.antiAlias,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                            border: Border.all(color: ApplicationTheme.appColorLightGrey, width: 1)),
                        margin: const EdgeInsets.only(right: 3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('S${episodes[index].season.toString().padLeft(2, '0')}',
                                maxLines: 1, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: ApplicationTheme.appColorLightGrey)),
                            Text('E${episodes[index].episode.toString().padLeft(2, '0')}',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: episodes[index].date != null
                                        ? (episodes[index].date!.isAfter(DateTime.now()) ? ApplicationTheme.appColorBlue : null)
                                        : null)),
                            SizedBox(
                              width: 25,
                              height: 20,
                              child: Checkbox(
                                value: episodes[index].seen,
                                onChanged: (value) {
                                  _client.markEpisode(episodes[index]);
                                  refresh();
                                },
                                visualDensity: VisualDensity.compact,
                                fillColor: MaterialStatePropertyAll(ApplicationTheme.appColorBlue),
                              ),
                            )
                          ],
                        ),
                      ),
                    ))));
          }
          return Container();
        });
  }

  Widget getListTilePopupActions(BuildContext context, Show show) {
    return PopupMenuButton(
        icon: Icon(Icons.more_vert, color: ApplicationTheme.appColorLighterGrey),
        itemBuilder: (context) => [getDeleteAction(context, show), getMoveAction(context, show)]);
  }

  PopupMenuEntry getDeleteAction(BuildContext context, Show show) {
    return PopupMenuItem(
      child: Text('Törlés', style: Theme.of(context).textTheme.titleLarge),
      onTap: () async {
        await _client.removeShow(show.id);
        refresh();
      },
    );
  }

  PopupMenuEntry getMoveAction(BuildContext context, Show show) {
    return PopupMenuItem(
      child: Text('Áthelyezés', style: Theme.of(context).textTheme.titleLarge),
      onTap: () async {
        var groups = (await _client.getGroups()).where((Group group) => group.index != widget._groupId);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          var result = await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: const Text("Áthelyezés másik lapra"),
                    children: groups
                        .map((group) => SimpleDialogOption(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                              onPressed: () {
                                Navigator.pop(context, group.index);
                              },
                              child: Text(group.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: ApplicationTheme.appColorBlue, fontWeight: FontWeight.normal)),
                            ))
                        .toList(),
                  ));
          await _client.move(show.id, result);
          refresh();
        });
      },
    );
  }

  Future refresh() async {
    final shows = await _client.getShows(widget._groupId, force: true);
    setState(() {
      _shows.clear();
      _shows.addAll(shows);
    });
  }

  void navigateToDetails(int showId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPage(showId)));
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
