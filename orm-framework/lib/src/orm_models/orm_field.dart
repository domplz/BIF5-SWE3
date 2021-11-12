import 'dart:mirrors';

import 'package:orm_framework/src/lazy.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../orm_framework.dart';

class OrmField {
  OrmField(this.entity, this.member, this.type, this.columnName, this.columnType, this.isPrimaryKey, this.isForeignKey, this.isNullable);

  OrmEntity entity;
  VariableMirror member;
  Type type;
  String columnName;
  Type columnType;
  bool isPrimaryKey;
  bool isForeignKey;
  bool isNullable;
  String? assignmentTable;
  String? remoteColumnName;
  bool isManyToMany = false;
  bool isExternal = false;

  String get fkSql {
    if(isManyToMany){
      return Orm.getEntity(reflectType(type).typeArguments.first.reflectedType).getSql() +
      " WHERE ID IN (SELECT $remoteColumnName FROM $assignmentTable WHERE $columnName = ?";
    }

    return "${Orm.getEntity(reflectType(type).typeArguments.first.reflectedType).getSql()} WHERE $columnName = ?";
  } 

  // is needed as string for parameter bindings
  // parameters in sqlite3 library can only be strings for some Reason
  String toColumnType(Object? value) {
    if (value == null) {
      return "";
    }

    if (isForeignKey) {
      Type t = type;
      if(reflectType(type).isAssignableTo(reflectType(Lazy))){
        t = reflectType(type).typeArguments.first.reflectedType;
      }
      return Orm.getEntity(t).primaryKey.toColumnType(Orm.getEntity(type).primaryKey.getValue(value));
    }

    // handle enums
    if (reflectClass(type).isEnum) {
      // returns integer
      return (value as Enum).index.toString();
    }

    if (type == columnType) {
      return value.toString();
    }

    // handle different field types
    if (value is bool) {
      if (columnType == int) {
        return (value ? 1 : 0).toString();
      }
    }

    return value.toString();
  }

  toFieldType(Object? value, List<Object>? localCache) {
    if (isForeignKey) {
      if (value != null) {
        if(reflectType(type).isAssignableTo(reflectType(Lazy))){
          return (reflectType(type) as ClassMirror).newInstance(Symbol(""), [value]).reflectee;
        }
        return Orm.createObject(type, value, localCache);
      }
    }

    if (type == bool) {
      if (value == null && !isNullable) {
        return false;
      }
      if (value is int) {
        return value != 0;
      }
    }

    if (type == int) {
      if (value == null && !isNullable) {
        return 0;
      }
      return value as int;
    }

    if (type == DateTime) {
      if (value == null && !isNullable) {
        return DateTime(0);
      }

      return DateTime.parse(value.toString());
    }

    if (reflectClass(type).isEnum) {
      // if not nullable, but value is null, use first value as default
      if (value == null && !isNullable) {
        value = 0;
      }

      // if nullable, return null.
      if (value == null && isNullable) {
        return null;
      }

      late InstanceMirror instance;
      var typeMirror = reflectType(type);
      if (typeMirror is ClassMirror) {
        List<String> enumValues = <String>[];
        for (var element in typeMirror.declarations.values) {
          // todo: find a better way to extract enum names
          if (!element.isPrivate &&
              element is VariableMirror &&
              element.isConst &&
              MirrorSystem.getName(element.simpleName) != "values" &&
              MirrorSystem.getName(element.simpleName) != MirrorSystem.getName(typeMirror.simpleName)) {
            enumValues.add("${MirrorSystem.getName(typeMirror.simpleName)}.${MirrorSystem.getName(element.simpleName)}");
          }
        }

        if (columnType == int) {
          instance = typeMirror.newInstance(Symbol(""), [value, enumValues[value as int]]);
        } else if (columnType == String) {
          instance = typeMirror.newInstance(Symbol(""), [enumValues.indexOf(value as String), value]);
        } else {
          throw Exception("ColumnType '$columnType' is not Suported!");
        }

        return instance.reflectee;
      } else {
        throw ArgumentError("Cannot create the instance of the type '$type'.");
      }
    }

    if (type == String && !isNullable && value == null) {
      return "";
    }

    return value;
  }

  Object? getValue(Object object) {
    if (member is VariableMirror) {
      InstanceMirror instanceMirror = reflect(object);
      if(object is Lazy){
        // no idea man
        return instanceMirror.getField(member.simpleName).reflectee;
      }
      return instanceMirror.getField(member.simpleName).reflectee;
    }
    throw Exception("Other types than VariableMirrors are not supportet for getValue!");
  }

  void setValue(Object object, Object value) {
    if (member is VariableMirror) {
      InstanceMirror instanceMirror = reflect(object);
      instanceMirror.setField(member.simpleName, value);
    }
    throw Exception("Other types than VariableMirrors are not supportet for setValue!");
  }

  Object fill(Object list, Object obj, List<Object>? localCache) {
    String commandText = "";
    if (isManyToMany) {
      commandText = Orm.getEntity(reflectType(type).typeArguments.first.reflectedType).getSql() +
          " WHERE ID IN (SELECT " +
          (remoteColumnName ?? "MISSING REMOTE COLUMN NAME") +
          " FROM " +
          (assignmentTable ?? "MISSING ASSIGNMENT TABLE") +
          " WHERE " +
          columnName +
          " = ? )";
    } else {
      commandText = Orm.getEntity(reflectType(type).typeArguments.first.reflectedType).getSql() + " WHERE " + columnName + " = ?";
    }

    List<String> parameters = <String>[];
    parameters.add(entity.primaryKey.toColumnType(entity.primaryKey.getValue(obj)));

    ResultSet resultSet = Orm.database.select(commandText, parameters);

    for (var result in resultSet) {
      // check if element is in cache
      var element =
          Orm.searchCache(reflectType(type).typeArguments.first.reflectedType, result[entity.primaryKey.columnName.toUpperCase()], localCache);

      // if element is null, load it from db
      element ??= Orm.createObjectFromRow(reflectType(type).typeArguments.first.reflectedType, result, localCache);

      (list as List).add(element);
    }

    return list;
  }

  void updateReferences(Object object) {
    if (!isExternal) {
      throw Exception("Update references can only be called on external fields!");
    }

    Type innerType = reflectType(type).typeArguments.first.reflectedType;
    OrmEntity innerEntity = Orm.getEntity(innerType);

    Object primaryKey = entity.primaryKey.toColumnType(entity.primaryKey.getValue(object));

    if (isManyToMany) {
      String command = "DELETE FROM $assignmentTable WHERE $columnName = ?";
      List<String> parameters = <String>[primaryKey.toString()];

      Orm.database.execute(command, parameters);

      for (Object element in getValue(object) as Iterable) {
        String command = "INSERT INTO $assignmentTable ( $columnName, $remoteColumnName ) VALUES (?,?)";
        List<String> parameters = <String>[
          primaryKey.toString(),
          innerEntity.primaryKey.toColumnType(innerEntity.primaryKey.getValue(element)),
        ];

        Orm.database.execute(command, parameters);
      }
    } else {
      OrmField remoteField = innerEntity.getFieldForColumn(columnName);

      if (remoteField.isNullable) {
        String command = "UPDATE ${innerEntity.tableName} + SET $columnName = NULL WHERE $columnName = ?";
        List<String> parameters = <String>[
          primaryKey.toString(),
        ];

        Orm.database.execute(command, parameters);

        for (Object element in getValue(object) as Iterable) {
          remoteField.setValue(element, object);

          String command = "UPDATE ${innerEntity.tableName} SET $columnName = ? WHERE ${innerEntity.primaryKey.columnName} = ?";
          List<String> parameters = <String>[
            primaryKey.toString(),
            innerEntity.primaryKey.toColumnType(innerEntity.primaryKey.getValue(element)),
          ];

          Orm.database.execute(command, parameters);
        }
      }
    }
  }
}
