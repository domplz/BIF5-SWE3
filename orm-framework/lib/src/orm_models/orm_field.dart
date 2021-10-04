import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';

class OrmField {
  OrmField(this.entity, this.member, this.type, this.columnName, this.columnType, this.isPrimaryKey, this.isForeignKey, this.isNullable);

  OrmEntity entity;
  DeclarationMirror member;
  Type type;
  String columnName;
  Type columnType;
  bool isPrimaryKey;
  bool isForeignKey;
  bool isNullable;
}
