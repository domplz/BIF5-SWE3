import 'dart:mirrors';

import 'package:orm_framework/src/cache.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:orm_framework/src/orm_models/query.dart';
import 'package:sqlite3/sqlite3.dart';

import 'orm_models/locking.dart';

class Orm {
  static final Map<Type, OrmEntity> _entities = <Type, OrmEntity>{};

  static late Database database;

  static Cache? cache;

  static Locking? locking;

  static OrmEntity getEntity(Object object) {
    // get type from object
    Type type;
    if (object is Type) {
      type = object;
    } else {
      type = object.runtimeType;
    }

    // add to dictonary if not allready in it
    if (!_entities.containsKey(type)) {
      _entities[type] = OrmEntity(type);
    }

    // ! is used, bc it was just added above
    return _entities[type]!;
  }

  static lock(Object object) {
    if (locking != null) {
      locking!.lock(object);
    }
  }

  static release(Object object) {
    if (locking != null) {
      locking!.release(object);
    }
  }

  static save(Object object) {
    if (cache != null && !cache!.hasChanged(object)) {
      return;
    }

    OrmEntity entity = Orm.getEntity(object);

    String commandText = "INSERT INTO ${entity.tableName} (";

    String update = "ON CONFLICT (${entity.primaryKey.columnName}) DO UPDATE SET ";
    String insert = "";

    List<String> parameters = <String>[];
    bool firstNonPrimaryKey = true;
    for (int i = 0; i < entity.internals.length; i++) {
      if (i > 0) {
        commandText += ", ";
        insert += ", ";
      }
      commandText += entity.internals[i].columnName;
      insert += " ? ";
      parameters.add(entity.internals[i].toColumnType(entity.internals[i].getValue(object)));
    }

    for (int i = 0; i < entity.internals.length; i++) {
      if (!entity.internals[i].isPrimaryKey) {
        if (firstNonPrimaryKey) {
          firstNonPrimaryKey = false;
        } else {
          update += ", ";
        }
        update += "${entity.internals[i].columnName} = ?";
        parameters.add(entity.internals[i].toColumnType(entity.internals[i].getValue(object)));
      }
    }
    commandText += ") VALUES ( $insert ) $update";

    database.execute(commandText, parameters);

    for (var field in entity.externals) {
      field.updateReferences(object);
    }

    if (cache != null) {
      cache!.put(object);
    }
  }

  static T get<T>(Object primaryKey) {
    return createObject(T, primaryKey, null) as T;
  }

  static List<T> getAll<T>() {
    var list = createAllObjects(T);
    List<T> typedList = <T>[];
    for (var object in list) {
      typedList.add(object as T);
    }

    return typedList;
  }

  static void delete(Object object) {
    OrmEntity entityToDelete = Orm.getEntity(object);

    String commandText = "DELETE FROM ${entityToDelete.tableName} WHERE ${entityToDelete.primaryKey.columnName} = ?";

    database.execute(commandText, [entityToDelete.primaryKey.getValue(object)]);

    if (cache != null) {
      cache!.remove(object);
    }
  }

  static Query<T> from<T>() {
    return Query<T>(null);
  }

  static List<T> fromSql<T>(String sql, [List<String>? parameters]) {
    return getListFromSql(T, sql, parameters ?? []);
  }

  static List<Object> createAllObjects(Type type) {
    String commandText = Orm.getEntity(type).getSql();
    ResultSet resultSet = database.select(commandText);

    if (resultSet.isEmpty) {
      throw Exception("The query did not return any rows. It returned an empty resultSet!");
    }

    List<Object> objects = <Object>[];
    for (var element in resultSet) {
      objects.add(createObjectFromRow(type, element, null));
    }

    return objects;
  }

  static Object createObject(Type t, Object primaryKey, List<Object>? localCache) {
    String commandText = Orm.getEntity(t).getSql() + " WHERE " + Orm.getEntity(t).primaryKey.columnName + " = ? ";
    ResultSet resultSet = database.select(commandText, [primaryKey]);

    if (resultSet.length != 1) {
      throw Exception("The query did not return 1 row. It returned " + resultSet.length.toString());
    }

    return createObjectFromRow(t, resultSet.first, localCache);
  }

  static Object createObjectFromRow(Type type, Map<String, dynamic> row, List<Object>? localCache) {
    var entity = Orm.getEntity(type);
    Object? cacheObject = searchCache(
        type, entity.primaryKey.toFieldType(row[entity.primaryKey.columnName.toUpperCase()], localCache), localCache);

    late InstanceMirror instance;
    if (cacheObject != null) {
      instance = reflect(cacheObject);
    } else {
      var typeMirror = reflectType(type);
      if (typeMirror is ClassMirror) {
        instance = typeMirror.newInstance(Symbol(""), const []);
      } else {
        throw ArgumentError("Cannot create the instance of the type '$type'.");
      }

      // add to cache
      localCache ??= [];
      localCache.add(instance.reflectee);
    }

    for (var element in entity.internals) {
      instance.setField(
          element.member.simpleName, element.toFieldType(row[element.columnName.toUpperCase()], localCache));
    }

    for (var element in entity.externals) {
      InstanceMirror externalInstance;
      var typeMirror = reflectType(element.type);
      if (typeMirror is ClassMirror) {
        externalInstance = typeMirror.newInstance(Symbol(""), const []);
      } else {
        throw ArgumentError("Cannot create the instance of the type '$type'.");
      }
      instance.setField(
          element.member.simpleName, element.fill(externalInstance.reflectee, instance.reflectee, localCache));
    }

    if (cache != null) {
      cache!.put(instance.reflectee);
    }

    return instance.reflectee;
  }

  static Object? searchCache(Type type, Object primaryKey, List<Object>? localCache) {
    if (cache != null && cache!.contains(type, primaryKey)) {
      return cache!.get(type, primaryKey);
    }

    if (localCache != null && localCache.isNotEmpty) {
      for (Object object in localCache) {
        if (object.runtimeType == type && Orm.getEntity(type).primaryKey.getValue(object) == primaryKey) {
          return object;
        }
      }
    }
  }

  static List<Type> getChildTypes(Type type) {
    List<Type> types = [];
    for (var item in _entities.keys) {
      if (!reflectClass(item).isAbstract && reflectType(item).isAssignableTo(reflectType(type))) {
        types.add(item);
      }
    }

    return types;
  }

  static List<T> getListFromSql<T>(Type type, String sql, List<String> parameters, [List<Object>? localCache]) {
    var results = database.select(sql, parameters);
    return _getListFromRow<T>(type, results, localCache);
  }

  static List<T> _getListFromRow<T>(Type type, ResultSet resultSet, [List<Object>? localCache]) {
    var list = <T>[];
    for (var item in resultSet) {
      var element = createObjectFromRow(type, item, localCache) as T;
      list.add(element);
    }

    return list;
  }
}
