import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';

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

  toColumnType(Object value){
    if(isForeignKey){
      return Orm.getEntity(type).primaryKey.toColumnType(
        Orm.getEntity(type).primaryKey.getValue(value)
        );
    }
    if(type == columnType){
      return value;
    }
    if(value == bool){
      if(columnType == int){
        return (value as bool) ? 1 : 0;
      }
    }

    return value;
  }

  toFieldType(Object value){
    if(type == bool){
      if(value is int){
        return value != 0;
      }
    }
    if(type == int){
      return value as int;
    }
    
    return value;
  }
  
  Object getValue(Object object){
    if(member.runtimeType.toString() == "_VariableMirror"){
      InstanceMirror instanceMirror = reflect(object);
      return instanceMirror.getField(member.simpleName).reflectee;
    }
    throw Exception("Other types than VariableMirrors are not supportet for getValue!");
  }

  void setValue(Object object, Object value){
    if(member.runtimeType.toString() == "_VariableMirror"){
      InstanceMirror instanceMirror = reflect(object);
      instanceMirror.setField(member.simpleName, value);
    }
    throw Exception("Other types than VariableMirrors are not supportet for setValue!");
  }
}
