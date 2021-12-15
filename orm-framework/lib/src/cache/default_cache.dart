import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/cache/cache.dart';

/// Simple [Cache] implementation, without change tracking.
class DefaultCache implements Cache {
  final Map<Type, Map<Object, Object>> _caches = <Type, Map<Object, Object>>{};

  Map<Object, Object> _getCache(Type type) {
    if (_caches.containsKey(type)) {
      return _caches[type]!;
    }

    var cacheObject = <Object, Object>{};
    _caches[type] = cacheObject;

    return cacheObject;
  }

  /// Checks, if object for [type] and [primaryKey] is in cache.
  /// Returns true, if object is in cache.
  /// Returns false, if object is not in cache.
  @override
  bool contains(Type type, Object primaryKey) {
    return _getCache(type).containsKey(primaryKey);
  }

  /// Checks, if [object] is in cache.
  /// Returns true, if object is in cache.
  /// Returns false, if object is not in cache.
  @override
  bool containsObject(Object object) {
    Object? pkValue = Orm.getEntity(object).primaryKey.getValue(object);

    if (pkValue != null) {
      return contains(object.runtimeType, pkValue);
    }

    return false;
  }

  /// Gets the object for [type] and [primaryKey] from cache
  /// Returns null, if not in cache.
  @override
  Object? get(Type type, Object primaryKey) {
    Map<Object, Object> cache = _getCache(type);

    if (cache.containsKey(primaryKey)) {
      return cache[primaryKey]!;
    }

    return null;
  }

  /// Puts [object] into cache.
  /// If primary key value of [object] is null, it will NOT be added to cache!
  @override
  void put(Object object) {
    var pkValue = Orm.getEntity(object).primaryKey.getValue(object);
    if (pkValue != null) {
      var cache = _getCache(object.runtimeType);
      cache[pkValue] = object;
    }
  }

  /// Removes [object] from cache.
  @override
  void remove(Object object) {
    var cache = _getCache(object.runtimeType);
    cache.remove(Orm.getEntity(object).primaryKey.getValue(object));
  }

  /// Checks, if [object] has changed.
  /// Change tracking not supportet!
  /// ALWAYS returns true.
  @override
  bool hasChanged(Object object) {
    return true;
  }
}
