abstract class Cache {
  T? get<T>(String key);

  void set<T>(String key, T value);

  bool has(String key);

  void remove(String key);
}
