import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:whatnext_flutter_client/models/episode.dart';
import 'package:whatnext_flutter_client/service/interface.dart';
import '../models/models.dart';

class WhatNextScraperClient extends WhatNextClient {
  WhatNextScraperClient({required this.baseUrl, required this.sessionCookie})
      : super();

  int _currentGroup = -1;
  final String baseUrl;
  final String sessionCookie;
  Map<int, List<Show>> groupCache = {};
  Map<int, Show> showCache = {};

  @override
  Future<List<Show>> getShows(int groupId, {bool force = false}) async {
    if (groupCache.containsKey(groupId) && !force) {
      return groupCache[groupId] ?? [];
    }

    if (groupId != _currentGroup) {
      await _changeGroup(groupId);
    }

    var doc = await _getWebpageContent();
    var shows = _findShows(doc);
    groupCache[groupId] = shows;
    showCache.addEntries(shows.map(
      (e) => MapEntry(e.id, e),
    ));
    return shows;
  }

  @override
  Future<Show?> getShow(int showId, {bool force = false}) async {
    Show? show = showCache[showId];
    if (show != null) {
      show.episodes = await getEpisodes(showId);
    }
    return show;
  }

  @override
  Future<List<Group>> getGroups() async {
    var doc = await _getWebpageContent();
    RegExp isActive = RegExp(r's[1-5]1');

    _currentGroup = int.parse(doc
            .querySelectorAll('div.grtab')
            .where((group) => isActive.hasMatch(group.className))
            .first
            .attributes['onclick']
            ?.split("'")[3] ??
        '1');

    return doc
        .querySelectorAll('div.grtab')
        .map((tab) => Group(
            index: int.parse(tab.attributes['onclick']?.split("'")[3] ?? '0'),
            title: tab.innerHtml.replaceAll('&nbsp;', ''),
            isActive: isActive.hasMatch(tab.className)))
        .take(5)
        .toList();
  }

  @override
  Future<List<Episode>> getEpisodes(int showId, {bool force = false}) async {
    return [
      Episode(
          season: 1,
          episode: 1,
          date: DateTime.now(),
          episodeName: 'Episode 1',
          showId: showId,
          seen: true),
      Episode(
          season: 1,
          episode: 2,
          date: DateTime.now(),
          episodeName: 'Episode 2',
          showId: showId,
          seen: true),
      Episode(
          season: 1,
          episode: 3,
          date: DateTime.now(),
          episodeName: 'Episode 3',
          showId: showId,
          seen: true),
      Episode(
          season: 1,
          episode: 4,
          date: DateTime.now(),
          episodeName: 'Episode 4',
          showId: showId,
          seen: false),
      Episode(
          season: 1,
          episode: 5,
          date: DateTime.now(),
          episodeName: 'Episode 5',
          showId: showId,
          seen: false),
    ];
  }

  Future _changeGroup(index) async {
    await http.Client().post(Uri.parse('$baseUrl/call.php?section=koveto'),
        headers: {'Cookie': sessionCookie},
        body: {'do': 'groupvalt', 'mit': index.toString()});
    _currentGroup = index;
  }

  Future<Document> _getWebpageContent() async {
    final response = await http.Client()
        .get(Uri.parse('$baseUrl/koveto'), headers: {'Cookie': sessionCookie});

    return parser.parse(response.body);
  }

  List<Show> _findShows(Document document) {
    return document
        .querySelectorAll("div.kbox")
        .map((item) => Show(
            groupId: _currentGroup,
            id: int.parse(item.id.split('_')[1]),
            name: item.children[0].attributes['title'] ?? '',
            banner: baseUrl +
                (item.children[0].children[0].attributes['src'] ?? ''),
            seasonActual:
                int.parse(item.querySelector("#sactual")?.innerHtml ?? ''),
            seasonAll: int.parse(item
                    .querySelector('#sall${item.id.split('_')[1]}')
                    ?.innerHtml ??
                '')))
        .toList();
  }
}
