abstract class AutoUpdater {

  Future<bool> checkForUpdate();
  Future<String> downloadUpdate();

  void skipVersion(String version);

  bool hasUpdate = false;
  String currentVersion = "";
  String latestVersion = "";
}
