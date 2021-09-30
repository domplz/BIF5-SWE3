import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';

class OrmEntity {
  OrmEntity(Type type){
    InstanceMirror instanceMirror = reflect(type);
  }

  late Type member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
}