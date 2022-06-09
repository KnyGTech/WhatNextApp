import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:whatnext_flutter_client/service/interface.dart';
import '../models/models.dart';

class WhatNextScraperClient extends WhatNextClient {
  WhatNextScraperClient({required this.baseUrl}) : super();

  int _currentGroup = -1;
  final String baseUrl;

  @override
  bool get isLoggedIn {
    return _sessionCookie != "";
  }

  String _sessionCookie = "";
  final Map<int, List<Show>> _groupCache = {};
  final Map<int, Show> _showCache = {};
  final Map<int, List<Episode>> _episodeCache = {};

  @override
  Future<List<Show>> getShows(int groupId, {bool force = false}) async {
    if (_groupCache.containsKey(groupId) && !force) {
      return _groupCache[groupId] ?? [];
    }

    if (groupId != _currentGroup) {
      await _changeGroup(groupId);
    }

    var doc = await _getWebpageContent();
    var shows = _findShows(doc);
    var episodes = _findEpisodes(doc);
    _groupCache[groupId] = shows;
    _showCache.addEntries(shows.map(
      (e) => MapEntry(e.id, e),
    ));
    var episodeGroups = groupBy(
        episodes, (Episode episode) => episode.showId * 100 + episode.season);
    _episodeCache.addAll(episodeGroups);
    return shows;
  }

  @override
  Future<Show?> getShow(int showId, {bool force = false}) async {
    Show? show = _showCache[showId];
    if (force) {
      await _changeGroup(show?.groupId);
      var doc = await _getWebpageContent();
      var shows = _findShows(doc);
      show = shows.where((show) => show.id == showId).first;
      _showCache[showId] = show;
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
  Future<List<Episode>> getEpisodes(int showId, int season,
      {bool force = false}) async {
    List<Episode>? showEpisodes = _episodeCache[showId * 100 + season];

    if (showEpisodes == null || force) {
      var show = _showCache[showId];
      await _changeGroup(show?.groupId);
      await _changeSeason(showId, season);
      var doc = await _getWebpageContent();
      var episodes = _findEpisodes(doc);
      showEpisodes =
          episodes.where((episode) => episode.showId == showId).toList();
      _episodeCache[showId * 100 + season] = showEpisodes;
    }

    return showEpisodes;
  }

  Future _changeGroup(index) async {
    await http.Client().post(Uri.parse('$baseUrl/call.php?section=koveto'),
        headers: {'Cookie': _sessionCookie},
        body: {'do': 'groupvalt', 'mit': index.toString()});
    _currentGroup = index;
  }

  Future<Document> _getWebpageContent() async {
    final response = await http.Client()
        .get(Uri.parse('$baseUrl/koveto'), headers: {'Cookie': _sessionCookie});

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

  List<Episode> _findEpisodes(Document document) {
    return document
        .querySelectorAll(".ep")
        .where((item) => !item.className.contains('cntdwn'))
        .map((item) => Episode(
            id: int.parse(
                item.children[0].attributes['onclick']?.split("'")[1] ?? '0'),
            date: DateTime.tryParse(item.attributes['title']
                    ?.split(RegExp(r'[\[\]]'))[1]
                    .replaceAll('.', '-') ??
                ''),
            seen: item.attributes['s'] == '1',
            season: int.parse(item.querySelector('span')?.innerHtml ?? '0'),
            episode: int.parse(item.children[0].nodes[3].text?.trim() ?? '0'),
            episodeName: item.querySelector('a.kd')?.attributes['ename'] ?? '',
            showId: int.parse(item.parent?.id.split('_')[1] ?? '0')))
        .toList();
  }

  Future _changeSeason(int showId, int season) async {
    Show? show = _showCache[showId];
    if (show != null) {
      await http.Client()
          .post(Uri.parse('$baseUrl/call.php?section=koveto'), headers: {
        'Cookie': _sessionCookie
      }, body: {
        'do': 'render_season',
        'sid': showId.toString(),
        'season': season.toString(),
        'all': show.seasonAll.toString()
      });
    }
    return;
  }

  @override
  Future markEpisode(Episode episode) async {
    await http.Client()
        .post(Uri.parse('$baseUrl/call.php?section=koveto/jelol'), headers: {
      'Cookie': _sessionCookie
    }, body: {
      'do': 'jelol',
      'mit': 's',
      'epid': episode.id.toString(),
      'e': episode.episode.toString().padLeft(2, '0'),
      's': episode.seen ? '1' : '0',
      'd': '0'
    });
  }

  @override
  Future<String> login(String user, String password) async {
    final response = await http.Client().post(
        Uri.parse('$baseUrl/call.php?section=index'),
        body: {'user': user, 'pass': password});
    if (response.body == "login:1") {
      final cookies = response.headers['set-cookie'] ?? "";
      final useridRegExp = RegExp(r'(userid=[0-9]+);');
      final loginpassRegExp = RegExp(r'(loginpass=[0-9a-z]+);');
      final userid = useridRegExp.firstMatch(cookies)?.group(1) ?? "";
      final loginpass = loginpassRegExp.firstMatch(cookies)?.group(1) ?? "";
      _sessionCookie = '$userid; $loginpass';
    }
    return response.body;
  }

  @override
  Future? logout() {
    _sessionCookie = "";
    _groupCache.clear();
    _showCache.clear();
    _episodeCache.clear();
    _currentGroup = -1;
    return null;
  }

  @override
  void setCredentials(String credentials) {
    logout();
    _sessionCookie = credentials;
  }

  @override
  String getCredentials() {
    return _sessionCookie;
  }
}
