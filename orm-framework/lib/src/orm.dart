import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:sqlite3/sqlite3.dart';

class Orm {
  static final Map<Type, OrmEntity> _entities = <Type, OrmEntity>{};

  static late Database database;

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

    var entity = _entities[type];
    if (entity != null) {
      return entity;
    }

    throw Exception("Entity in dictionary is null! (Should not happen, as it was just added)");
  }

  static save(Object object) async {
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
      insert += "?";
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

  static List<Object> createAllObjects(Type t) {
    String commandText = Orm.getEntity(t).getSql();
    ResultSet resultSet = database.select(commandText);

    if (resultSet.isEmpty) {
      throw Exception("The query did not return any rows. It returned " + resultSet.length.toString());
    }
    List<Object> objects = <Object>[];
    for (var element in resultSet) {
      objects.add(createObjectFromRow(t, element, null));
    }
    return objects;
  }

  static Object createObject(Type t, Object primaryKey, List<Object>? localCache) {
    Object? cacheObject = searchCache(t, primaryKey, localCache);

    if (cacheObject != null) {
      return cacheObject;
    }

    String commandText = Orm.getEntity(t).getSql() + " WHERE " + Orm.getEntity(t).primaryKey.columnName + " = ? ";
    ResultSet resultSet = database.select(commandText, [primaryKey]);

    if (resultSet.length != 1) {
      throw Exception("The query did not return 1 row. It returned " + resultSet.length.toString());
    }

    return createObjectFromRow(t, resultSet.first, localCache);
  }

  static Object createObjectFromRow(Type type, Row row, List<Object>? localCache) {
    var entity = Orm.getEntity(type);
    Object? cacheObject = searchCache(type, entity.primaryKey.toFieldType(row[entity.primaryKey.columnName.toUpperCase()], localCache), localCache);

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
    }

    localCache ??= <Object>[];
    localCache.add(instance.reflectee);

    for (var element in entity.internals) {
      instance.setField(element.member.simpleName, element.toFieldType(row[element.columnName.toUpperCase()], localCache));
    }

    for (var element in entity.externals) {
      InstanceMirror externalInstance;
      var typeMirror = reflectType(element.type);
      if (typeMirror is ClassMirror) {
        externalInstance = typeMirror.newInstance(Symbol(""), const []);
      } else {
        throw ArgumentError("Cannot create the instance of the type '$type'.");
      }
      instance.setField(element.member.simpleName, element.fill(externalInstance.reflectee, instance.reflectee, localCache));
    }

    return instance.reflectee;
  }

  static Object? searchCache(Type type, Object primaryKey, List<Object>? localCache) {
    if (localCache != null) {
      for (Object object in localCache) {
        if (object.runtimeType != type) {
          continue;
        }

        if (Orm.getEntity(type).primaryKey.getValue(object) == primaryKey) {
          return object;
        }
      }
    }
  }
}
