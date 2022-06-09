import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/interfaces.dart';
import '../services/services.dart';

class ServiceConfigurator {
  static Future<bool> setup() async {
    final getIt = GetIt.instance;

    if (!getIt.isRegistered<WhatNextClient>() ||
        !getIt.isRegistered<Cache>() ||
        !getIt.isRegistered<CredentialManager>()) {
      final prefs = await SharedPreferences.getInstance();
      final cache = SharedPreferencesCache(prefs);
      final credentialManager = WhatNextCacheCredentialManager(cache);
      final client = ScraperWhatNextClient(
          baseUrl: 'https://whatnext.cc', credentialManager: credentialManager);

      getIt.registerSingleton<WhatNextClient>(client);
      getIt.registerSingleton<Cache>(cache);
      getIt.registerSingleton<CredentialManager>(credentialManager);
    }

    return true;
  }
}
