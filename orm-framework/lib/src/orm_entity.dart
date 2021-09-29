import 'package:orm_framework/src/orm_field.dart';

class OrmEntity {
  
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
  late OrmField foreignKey;
}