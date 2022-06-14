import 'episode.dart';

class Show {
  Show(
      {required this.id,
      required this.groupId,
      required this.name,
      required this.banner,
      required this.seasonActual,
      required this.seasonAll});

  int id;
  int groupId;
  String name;
  String banner;
  int seasonActual;
  int seasonAll;

  String? hungarianTitle;
  String? genre;
  String? status;
  String? cover;
  String? statistics;


  List<Episode> episodes = [];
}
