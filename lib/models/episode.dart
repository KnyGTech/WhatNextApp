import 'package:flutter/material.dart';

class Episode {
  Episode(
      {required this.id,
      required this.season,
      required this.episode,
      required this.date,
      required this.episodeName,
      required this.showId,
      required this.seen});

  int id;
  int season;
  int episode;
  DateTime? date;
  String episodeName;
  int showId;
  bool seen;
}
