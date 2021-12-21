import 'package:orm_framework/src/annotations/field_annotation.dart';

/// Primary key field annotations used on property level to mark a column as primary key in sql.
class PrimaryKeyAnnotation extends FieldAnnotation {
  const PrimaryKeyAnnotation({String? columnName, Type? columnType})
      : super(columnName: columnName, columnType: columnType, nullable: false);
}
