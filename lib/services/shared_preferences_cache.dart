import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatnext_flutter_client/interfaces/interfaces.dart';

class SharedPreferencesCache implements Cache {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesCache(this._sharedPreferences) : super();

  @override
  T? get<T>(String key) {
    if (has(key)) {
      switch (T) {
        case String:
          return _sharedPreferences.getString(key) as T;
        case int:
          return _sharedPreferences.getInt(key) as T;
        case bool:
          return _sharedPreferences.getBool(key) as T;
        case double:
          return _sharedPreferences.getDouble(key) as T;
        default:
          return jsonDecode(_sharedPreferences.getString(key)!) as T;
      }
    }
    return null;
  }

  @override
  bool has(String key) {
    return _sharedPreferences.get(key) != null;
  }

  @override
  void remove(String key) {
    if (has(key)) {
      _sharedPreferences.remove(key);
    }
  }

  @override
  void set<T>(String key, T value) {
    switch (T) {
      case String:
        _sharedPreferences.setString(key, value as String);
        break;
      case int:
        _sharedPreferences.setInt(key, value as int);
        break;
      case bool:
        _sharedPreferences.setBool(key, value as bool);
        break;
      case double:
        _sharedPreferences.setDouble(key, value as double);
        break;
      default:
        _sharedPreferences.setString(key, jsonEncode(value));
    }
  }
}
