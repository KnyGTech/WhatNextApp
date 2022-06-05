import 'package:whatnext_flutter_client/models/episode.dart';

import '../models/models.dart';

abstract class WhatNextClient{
  Future<List<Group>> getGroups();
  Future<List<Show>> getShows(int groupId, {bool force = false});
  Future<List<Episode>> getEpisodes(int showId, {bool force = false});
}