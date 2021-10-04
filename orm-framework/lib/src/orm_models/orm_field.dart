import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';

class OrmField {
  OrmField(this.entity);

  late OrmEntity entity;
  late DeclarationMirror member;
  late Type type;
  late String columnName;
  late Type columnType;
  late bool isPrimaryKey = false;
  late bool isForeignKey = false;
  late bool isNullable = false;
}
