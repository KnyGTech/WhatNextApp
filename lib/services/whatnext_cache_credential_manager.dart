import 'package:whatnext/_lib.dart';

class WhatNextCacheCredentialManager implements CredentialManager {
  final Cache _cache;
  static const String credentialKey = 'whatnext-credentials';

  WhatNextCacheCredentialManager(this._cache) : super();

  @override
  bool hasCredentials() {
    return _cache.has(credentialKey);
  }

  @override
  void removeCredentials() {
    _cache.remove(credentialKey);
  }

  @override
  String restore() {
    return _cache.get<String>(credentialKey) ?? "";
  }

  @override
  void save(credentials) {
    _cache.set<String>(credentialKey, credentials);
  }
}
