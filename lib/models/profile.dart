import 'package:whatnext/_lib.dart';

class Profile {
  Profile(
      {required this.name,
      required this.email,
      required this.avatar,
      required this.statistics,
      required this.shows,
      required this.activities});

  final String name;
  final String email;
  final String avatar;
  final String statistics;
  final List<String> shows;
  final List<Activity> activities;
}
