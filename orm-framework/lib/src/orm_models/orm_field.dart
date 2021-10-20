import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../orm_framework.dart';

class OrmField {
  OrmField(this.entity, this.member, this.type, this.columnName,
      this.columnType, this.isPrimaryKey, this.isForeignKey, this.isNullable);

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

  // is needed as string for parameter bindings
  // parameters in sqlite3 library can only be strings for some Reason
  String toColumnType(Object value) {
    if (isForeignKey) {
      return Orm.getEntity(type)
          .primaryKey
          .toColumnType(Orm.getEntity(type).primaryKey.getValue(value));
    }

    // handle enums
    if (reflectClass(columnType).isEnum) {
      // returns integer
      return (value as Enum).index.toString();
    }

    if (type == columnType) {
      return value.toString();
    }

    // handle different field types
    if (value == bool) {
      if (columnType == int) {
        return ((value as bool) ? 1 : 0).toString();
      }
    }

    return value.toString();
  }

  toFieldType(Object? value, List<Object>? localCache) {
    if (isForeignKey) {
      if (value != null) {
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
              MirrorSystem.getName(element.simpleName) !=
                  MirrorSystem.getName(typeMirror.simpleName)) {
            enumValues.add("${MirrorSystem.getName(typeMirror.simpleName)}.${MirrorSystem.getName(element.simpleName)}");
          }
        }

        if (columnType == int) {
          instance = typeMirror
              .newInstance(Symbol(""), [value, enumValues[value as int]]);
        }

        else if (columnType == String) {
          instance = typeMirror.newInstance(
              Symbol(""), [enumValues.indexOf(value as String), value]);
        }
        else {
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

  Object getValue(Object object) {
    if (member is VariableMirror) {
      InstanceMirror instanceMirror = reflect(object);
      return instanceMirror.getField(member.simpleName).reflectee;
    }
    throw Exception(
        "Other types than VariableMirrors are not supportet for getValue!");
  }

  void setValue(Object object, Object value) {
    if (member is VariableMirror) {
      InstanceMirror instanceMirror = reflect(object);
      instanceMirror.setField(member.simpleName, value);
    }
    throw Exception(
        "Other types than VariableMirrors are not supportet for setValue!");
  }

  Object fill(Object list, Object obj, List<Object>? localCache) {
    String commandText = "";
    if (isManyToMany) {
      commandText =
          Orm.getEntity(reflectType(type).typeArguments.first.reflectedType)
                  .getSql() +
              "WHERE ID IN (SELECT " +
              (remoteColumnName ?? "MISSING REMOTE COLUMN NAME") +
              " FROM " +
              (assignmentTable ?? "MISSING ASSIGNMENT TABLE") +
              " WHERE " +
              columnName +
              " = ? )";
    } else {
      commandText =
          Orm.getEntity(reflectType(type).typeArguments.first.reflectedType)
                  .getSql() +
              " WHERE " +
              columnName +
              " = ?";
    }

    List<String> parameters = <String>[];
    parameters
        .add(entity.primaryKey.toColumnType(entity.primaryKey.getValue(obj)));

    ResultSet resultSet = Orm.database.select(commandText, parameters);

    for (var result in resultSet) {
      (list as List).add(Orm.createObjectFromRow(
          reflectType(type).typeArguments.first.reflectedType,
          result,
          localCache));
    }

    return list;
  }
}
