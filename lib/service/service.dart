import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import '../models/models.dart';

class WhatNextClient {
  WhatNextClient({required this.baseUrl, required this.sessionCookie});

  final String baseUrl;
  final String sessionCookie;

  Future<List<Show>> getShows() async {
    var doc = await getWebpageContent();
    return findShows(doc);
  }

  Future<List<String>> getGroups() async {
    var doc = await getWebpageContent();
    return doc
        .querySelectorAll('div.grtab')
        .map((tab) => tab.innerHtml.replaceAll('&nbsp;', ''))
        .take(5)
        .toList();
  }

  changeGroup(index) {
    http.Client().post(Uri.parse('$baseUrl/call.php?section=koveto'),
        headers: {'Cookie': sessionCookie},
        body: {'do': 'groupvalt', 'mit': index.toString()});
  }

  Future<Document> getWebpageContent() async {
    final response = await http.Client()
        .get(Uri.parse('$baseUrl/koveto'), headers: {'Cookie': sessionCookie});

    return parser.parse(response.body);
  }

  List<Show> findShows(Document document) {
    return document
        .querySelectorAll("div.kbox")
        .map((item) => Show(
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
