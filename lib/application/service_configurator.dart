import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatnext_flutter_client/events/new_show_added_event.dart';
import 'package:whatnext_flutter_client/interfaces/auto_updater.dart';

import '../interfaces/interfaces.dart';
import '../services/services.dart';

class ServiceConfigurator {
  static Future<bool> setup() async {
    final getIt = GetIt.instance;

    if (!getIt.isRegistered<WhatNextClient>()) {
      final prefs = await SharedPreferences.getInstance();
      final cache = SharedPreferencesCache(prefs);
      final credentialManager = WhatNextCacheCredentialManager(cache);
      final client = ScraperWhatNextClient(
          baseUrl: 'https://whatnext.cc', credentialManager: credentialManager);
      final updater = GithubReleaseAutoUpdater(cache,
          repoUrl: "KisGaben/WhatnextFlutterClient",
          accessToken: "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");
      await updater.checkForUpdate();

      try {
        // services
        getIt.registerSingleton<WhatNextClient>(client);
        getIt.registerSingleton<Cache>(cache);
        getIt.registerSingleton<CredentialManager>(credentialManager);
        getIt.registerSingleton<AutoUpdater>(updater);

        // events
        getIt.registerSingleton<NewShowAddedEvent>(NewShowAddedEvent());
      } catch (e) {
        print(e);
      }
    }

    return true;
  }
}
