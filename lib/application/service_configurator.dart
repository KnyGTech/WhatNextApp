import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatnext_flutter_client/events/new_show_added_event.dart';

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

      // services
      getIt.registerSingleton<WhatNextClient>(client);
      getIt.registerSingleton<Cache>(cache);
      getIt.registerSingleton<CredentialManager>(credentialManager);

      // events
      getIt.registerSingleton<NewShowAddedEvent>(NewShowAddedEvent());

    }

    return true;
  }
}
