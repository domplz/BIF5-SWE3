import 'package:orm_framework/src/orm_entity.dart';

class OrmField {
  OrmField(this.entity);

  late OrmEntity entity;
  late String fieldName;
  late Type type;
  late bool nullable;
}