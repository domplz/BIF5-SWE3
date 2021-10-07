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
    for (int i = 0; i < entity.fields.length; i++) {
      if (i > 0) {
        commandText += ", ";
        insert += ", ";
      }
      commandText += entity.fields[i].columnName;
      insert += "?";
      parameters.add(entity.fields[i].toColumnType(entity.fields[i].getValue(object)));
    }

    for (int i = 0; i < entity.fields.length; i++) {
      if (!entity.fields[i].isPrimaryKey) {
        if (firstNonPrimaryKey) {
          firstNonPrimaryKey = false;
        } else {
          update += ", ";
        }
        update += "${entity.fields[i].columnName} = ?";
        parameters.add(entity.fields[i].toColumnType(entity.fields[i].getValue(object)));
      }
    }
    commandText += ") VALUES ( $insert ) $update";

    database.execute(commandText, parameters);
  }

  static T get<T>(Object primaryKey) {
    return _createObject(T, primaryKey) as T;
  }

  static List<T> getAll<T>() {
    var list = _createAllObjects(T);
    List<T> typedList = <T>[];
    for (var object in list) {
      typedList.add(object as T);
    }

    return typedList;
  }

  static List<Object> _createAllObjects(Type t) {
    String commandText = Orm.getEntity(t).getSql();
    ResultSet resultSet = database.select(commandText);

    if (resultSet.isEmpty) {
      throw Exception("The query did not return any rows. It returned " + resultSet.length.toString());
    }
    List<Object> objects = <Object>[];
    for (var element in resultSet) {
      objects.add(_createObjectFromRow(t, element));
    }
    return objects;
  }

  static Object _createObject(Type t, Object primaryKey) {
    String commandText = Orm.getEntity(t).getSql() + " WHERE " + Orm.getEntity(t).primaryKey.columnName + " = ? ";
    ResultSet resultSet = database.select(commandText, [primaryKey]);

    if (resultSet.length != 1) {
      throw Exception("The query did not return 1 row. It returned " + resultSet.length.toString());
    }

    return _createObjectFromRow(t, resultSet.first);
  }

  static Object _createObjectFromRow(Type type, Row row) {
    late InstanceMirror instance;
    var typeMirror = reflectType(type);
    if (typeMirror is ClassMirror) {
      instance = typeMirror.newInstance(Symbol(""), const []);
    } else {
      throw ArgumentError("Cannot create the instance of the type '$type'.");
    }

    var entityFields = Orm.getEntity(type).fields;

    for (var element in entityFields) {
      instance.setField(element.member.simpleName, element.toFieldType(row[element.columnName.toUpperCase()]));
    }

    return instance.reflectee;
  }
}
