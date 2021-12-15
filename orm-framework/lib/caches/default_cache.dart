import 'package:orm_framework/caches/cache.dart';
import 'package:orm_framework/orm_framework.dart';

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

  @override
  bool contains(Type type, Object primaryKey) {
    return _getCache(type).containsKey(primaryKey);
  }

  @override
  bool containsObject(Object object) {
    Object? pkValue = Orm.getEntity(object).primaryKey.getValue(object);

    if (pkValue != null) {
      return contains(object.runtimeType, pkValue);
    }

    return false;
  }

  @override
  Object? get(Type type, Object primaryKey) {
    Map<Object, Object> cache = _getCache(type);

    if (cache.containsKey(primaryKey)) {
      return cache[primaryKey]!;
    }

    return null;
  }

  @override
  void put(Object object) {
    var pkValue = Orm.getEntity(object).primaryKey.getValue(object);
    if (pkValue != null) {
      var cache = _getCache(object.runtimeType);
      cache[pkValue] = object;
    }
  }

  @override
  void remove(Object object) {
    var cache = _getCache(object.runtimeType);
    cache.remove(Orm.getEntity(object).primaryKey.getValue(object));
  }

  @override
  bool hasChanged(Object object) {
    return true;
  }
}
