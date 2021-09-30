import 'package:orm_framework/src/orm_models/orm_field.dart';

class OrmEntity {
  OrmEntity(Type type){
  }

  late Type member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
}