import 'package:orm_framework/src/orm_metadata/field_metadata.dart';

class PrimaryKeyMetadata extends FieldMetadata {
  const PrimaryKeyMetadata([String? columnName, Type? columnType]) : super(columnName, columnType, false);
}
