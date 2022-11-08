import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:whatnext_flutter_client/interfaces/interfaces.dart';
import 'package:whatnext_flutter_client/models/models.dart';

class ScraperWhatNextClient extends WhatNextClient {
  ScraperWhatNextClient(
      {required this.baseUrl, required this.credentialManager})
      : super() {
    if (credentialManager.hasCredentials()) {
      _sessionCookie = credentialManager.restore();
    }
  }

  int _currentGroup = -1;
  final String baseUrl;
  final CredentialManager credentialManager;

  @override
  bool get isLoggedIn {
    return _sessionCookie != "";
  }

  String _sessionCookie = "";
  final Map<int, List<Show>> _groupCache = {};
  final Map<int, Show> _showCache = {};
  final Map<int, List<Episode>> _episodeCache = {};
  Profile? _profileCache;

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

    shows = shows.map((s) {
      if(episodes.where((ep) => !ep.seen && ep.showId == s.id && DateTime.now().isBefore(ep.date ?? DateTime.now().subtract(const Duration(days: 1)))).isNotEmpty) {
        s.indicator = false;
      }
      else if(episodes.where((ep) => !ep.seen && ep.showId == s.id).isEmpty){
        s.indicator = true;
      }
      return s;
    }).toList();

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
    await _getShowDetails(showId);
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
    if (_currentGroup == index) return;
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

  Future _getShowDetails(int showId) async {
    Show? show = _showCache[showId];
    if (show != null) {
      final response = await http.Client().get(
          Uri.parse('$baseUrl/sorozatok/?sid=$showId'),
          headers: {'Cookie': _sessionCookie});

      var document = parser.parse(response.body);
      show.hungarianTitle = document.querySelector('span.sbox_txt')?.innerHtml;
      var sbox = document.querySelector('div.sbox_content');
      show.status = sbox?.nodes[sbox.nodes.length - 1].text?.trim();
      show.genre = sbox?.nodes[sbox.nodes.length - 3].text?.trim();
      await _getShowCoverAndStat(show);
    }
  }

  Future _getShowCoverAndStat(Show show) async {
    final response = await http.Client().post(
        Uri.parse('$baseUrl/call.php?section=sorozatok'),
        headers: {'Cookie': _sessionCookie},
        body: {'menu': 'm1', 'sid': show.id.toString()});

    var document = parser.parse(response.body);
    show.cover = document.querySelector('img')?.attributes['src'];
    show.statistics = document.querySelector('span.sstat')?.innerHtml.trim();
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
      credentialManager.save(_sessionCookie);
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
    credentialManager.removeCredentials();
    return null;
  }

  @override
  Future<List<SearchResult>> search(String query) async {
    var response = await http.Client()
        .post(Uri.parse('$baseUrl/call.php?section=koveto'), headers: {
      'Cookie': _sessionCookie
    }, body: {
      'do': 'livesearch',
      'gyorskereso': query,
    });

    final Document doc = parser.parse(response.body);
    return doc
        .querySelectorAll('tr')
        .map((item) => SearchResult(
              id: int.parse(item
                      .querySelector('a[href="#add"]')
                      ?.attributes['onclick']
                      ?.split("'")[1] ??
                  '0'),
              name: item.querySelector('a[href="#add"]')?.innerHtml ?? '',
              banner: baseUrl +
                  (item.querySelector('img')?.attributes['src'] ?? ''),
            ))
        .toList();
  }

  @override
  Future<String> addShow(int showId, int groupId) async {
    await _changeGroup(groupId);
    var response = await http.Client()
        .post(Uri.parse('$baseUrl/call.php?section=koveto'), headers: {
      'Cookie': _sessionCookie
    }, body: {
      'do': 'addserie',
      'sid': showId.toString(),
    });
    return response.body.replaceAll('<br>', '');
  }

  @override
  Future<String> removeShow(int showId) async {
    var response = await http.Client()
        .post(Uri.parse('$baseUrl/call.php?section=koveto'), headers: {
      'Cookie': _sessionCookie
    }, body: {
      'do': 'removeserie',
      'sid': showId.toString(),
    });
    return response.body;
  }

  @override
  Future reorder(List<int> showIds, int groupId) async {
    var body = {
      'do': 'sortable',
      'group': groupId.toString(),
    };

    for (int i = 0; i < showIds.length; i++) {
      body['id[$i]'] = showIds[i].toString();
    }

    await http.Client().post(Uri.parse('$baseUrl/call.php?section=koveto'),
        headers: {'Cookie': _sessionCookie}, body: body);
  }

  @override
  Future move(int showId, int groupId) async {
    var shows =
        (await getShows(groupId, force: true)).map((show) => show.id).toList();

    shows.add(showId);

    await reorder(shows, groupId);

    await getShows(groupId, force: true);
  }

  @override
  Future renameGroup(int groupId, String newName) async {
    await http.Client().post(Uri.parse('$baseUrl/call.php?section=koveto'),
        headers: {'Cookie': _sessionCookie},
        body: {'do': 'rename', 'mit': 'grname$groupId', 'mire': newName});
  }

  @override
  Future<Profile> getProfile({bool force = false}) async {
    if (_profileCache == null || force) {
      var profileResult = await http.Client().get(
          Uri.parse('$baseUrl/felhasznalo'),
          headers: {'Cookie': _sessionCookie});
      var profileDocument = parser.parse(profileResult.body);

      var statResult = await http.Client().get(
          Uri.parse('$baseUrl/statisztika'),
          headers: {'Cookie': _sessionCookie});
      var statDocument = parser.parse(statResult.body);

      var settingsResult = await http.Client().get(
          Uri.parse('$baseUrl/beallitasok'),
          headers: {'Cookie': _sessionCookie});
      var settingsDocument = parser.parse(settingsResult.body);

      _profileCache = Profile(
          name: profileDocument
                  .querySelector('div#usr3')
                  ?.children[0]
                  .innerHtml ??
              '',
          email: settingsDocument
              .querySelectorAll('table.config')[2]
              .querySelectorAll('td')[5]
              .innerHtml,
          avatar: baseUrl +
              (profileDocument.querySelector('img.av')?.attributes['src'] ??
                  ''),
          statistics:
              statDocument.querySelectorAll('span.big-text')[1].innerHtml,
          shows: await _getAllShow(),
          activities: profileDocument
              .querySelectorAll('div.x34 table tr')
              .map((item) => Activity(
                  show: item.children[1].innerHtml.trim(),
                  episode:
                      '${item.children[3].innerHtml.trim()}: ${item.children[2].innerHtml.trim()}',
                  time: item.children[4].innerHtml.trim(),
                  banner: baseUrl +
                      (item.querySelector('img')?.attributes['src'] ?? '')))
              .toList());
    }
    return _profileCache!;
  }

  Future<List<String>> _getAllShow() async {
    final List<String> shows = [];

    var result = await http.Client().get(Uri.parse('$baseUrl/felhasznalo'),
        headers: {'Cookie': _sessionCookie});
    var document = parser.parse(result.body);

    shows.addAll(document
        .querySelectorAll('div.listikon img')
        .map((item) => baseUrl + (item.attributes['src'] ?? '')));

    if (document.querySelector('div#owns') != null) {
      var userID =
          document.querySelectorAll('table.config td').last.innerHtml.trim();
      var moreResult = await http.Client().post(
          Uri.parse('$baseUrl/call.php?section=profile'),
          headers: {'Cookie': _sessionCookie},
          body: {'do': 'getall', 'sessionid': userID});
      var moreDocument = parser.parse(moreResult.body);

      shows.addAll(moreDocument
          .querySelectorAll('img')
          .map((item) => baseUrl + (item.attributes['src'] ?? '')));
    }
    return shows;
  }

  @override
  String getRegisterLink() {
    return "$baseUrl/regisztracio";
  }
}
