import 'package:orm_framework/src/orm_metadata/field_metadata.dart';

class ForeignKeyMetadata extends FieldMetadata {
  const ForeignKeyMetadata([String? columnName, Type? columnType, bool? nullable]) : super(columnName, columnType, nullable);
}
