import '../models/models.dart';

abstract class WhatNextClient{
  Future<List<Group>> getGroups();
  Future<List<Show>> getShows(int groupId);
}