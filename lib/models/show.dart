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
  List<Episode> episodes = [];
}
