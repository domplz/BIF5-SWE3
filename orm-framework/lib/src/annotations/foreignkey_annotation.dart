import 'package:orm_framework/src/annotations/field_annotation.dart';

class ForeignKeyAnnotation extends FieldAnnotation {
  const ForeignKeyAnnotation([String? columnName, Type? columnType, bool? nullable]) : super(columnName, columnType, nullable);
}
