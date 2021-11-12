abstract class Cache {
  Object? get(Type type, Object primaryKey);

  void put(Object object);

  void remove(Object object);

  bool contains(Type type, Object primaryKey);

  bool containsObject(Object object);

  bool hasChanged(Object object);
}
