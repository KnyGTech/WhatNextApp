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

  bool get isLoggedIn;

  Future<List<SearchResult>> search(String query);

  Future<String> addShow(int showId, int groupId);

  Future<String> removeShow(int showId);

  Future reorder(List<int> showIds, int groupId);

  Future move(int showId, int groupId);

  Future renameGroup(int groupId, String newName);

  Future<Profile> getProfile({bool force = false});
}
