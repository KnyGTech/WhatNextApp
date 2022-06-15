import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:whatnext_flutter_client/interfaces/interfaces.dart';

class GithubReleaseAutoUpdater implements AutoUpdater {
  final Cache _cache;
  final String _skippedVersionsCacheKey = 'auto-updater-skipped-versions';

  final String baseUrl = "https://api.github.com/repos/";
  final String repoUrl;
  final String accessToken;

  @override
  String currentVersion = "";
  @override
  String latestVersion = "";
  @override
  bool hasUpdate = false;

  String _updateLink = "";
  String _updateName = "";

  GithubReleaseAutoUpdater(this._cache,
      {required this.repoUrl, required this.accessToken});

  @override
  Future<bool> checkForUpdate() async {
    var request = await http.Client()
        .get(Uri.parse('$baseUrl$repoUrl/releases/latest'), headers: {
      'Accept': 'application/vnd.github.v3+json',
      'Authorization': 'token $accessToken',
    });

    if (request.statusCode != 200) {
      return false;
    }

    var release = jsonDecode(request.body);
    currentVersion = await _getCurrentVersion();
    latestVersion = release["name"];
    _updateLink = release["assets"][0]["url"];
    _updateName = release["assets"][0]["name"];

    hasUpdate = _compareVersions(currentVersion, latestVersion);
    return hasUpdate;
  }

  Future<String> _getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool _compareVersions(String currentVersion, String latestVersion) {
    if (!_isVersionSkipped(latestVersion)) {
      var current = currentVersion.split('.');
      var latest = latestVersion.split('.');
      for (int i = 0; i < current.length; i++) {
        if (int.parse(latest[i]) > int.parse(current[i])) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void skipVersion(String version) {
    final List<String> skippedVersions = [];
    if (_cache.has(_skippedVersionsCacheKey)) {
      skippedVersions
          .addAll(_cache.get<List<String>>(_skippedVersionsCacheKey) ?? []);
    }
    skippedVersions.add(version);
    _cache.set(_skippedVersionsCacheKey, skippedVersions);
  }

  bool _isVersionSkipped(String version) {
    final List<String> skippedVersions = [];
    if (_cache.has(_skippedVersionsCacheKey)) {
      skippedVersions
          .addAll(_cache.get<List<String>>(_skippedVersionsCacheKey) ?? []);
    }
    return skippedVersions.contains(version);
  }

  @override
  Future<String> downloadUpdate() async{
    if(hasUpdate) {
      try {
        var response = await http.Client().get(
            Uri.parse(_updateLink), headers: {
          'Accept': 'application/octet-stream',
          'Authorization': 'token $accessToken',
        });
        if (response.statusCode == 200) {
          var filePath = '/storage/emulated/0/Download/$_updateName';
          var file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          return filePath;
        }
      }
      catch(e){
        return "";
      }
    }
    return "";
  }

}
