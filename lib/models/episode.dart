import 'package:flutter/material.dart';

class Episode {
  Episode(
      {required this.season,
      required this.episode,
      required this.date,
      required this.episodeName,
      required this.showId,
      required this.seen});

  int season;
  int episode;
  DateTime date;
  String episodeName;
  int showId;
  bool seen;
}
