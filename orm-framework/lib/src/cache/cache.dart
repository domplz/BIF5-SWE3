/// Abstract [Cache] implementation.
abstract class Cache {
  /// Gets the object for [type] and [primaryKey] from cache
  Object? get(Type type, Object primaryKey);

  /// Puts [object] into cache.
  void put(Object object);

  /// Removes [object] from cache
  void remove(Object object);

  /// Checks, if object for [type] and [primaryKey] is in cache.
  bool contains(Type type, Object primaryKey);

  /// Checks, if [object] is in cache.
  bool containsObject(Object object);

  /// Checks, if [object] has changed.
  bool hasChanged(Object object);
}
