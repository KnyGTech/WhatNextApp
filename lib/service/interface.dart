import 'package:whatnext_flutter_client/models/episode.dart';

import '../models/models.dart';

abstract class WhatNextClient {
  Future<List<Group>> getGroups();

  Future<List<Show>> getShows(int groupId, {bool force = false});

  Future<Show?> getShow(int showId, {bool force = false});

  Future<List<Episode>> getEpisodes(int showId, int season,
      {bool force = false});

  Future markEpisode(Episode episode);

  Future<String> login(String user, String password);

  Future? logout();

  void setCredentials(String credentials);

  String getCredentials();



  bool get isLoggedIn;
}
