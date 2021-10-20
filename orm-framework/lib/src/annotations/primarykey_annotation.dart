import 'package:orm_framework/src/annotations/field_annotation.dart';

class PrimaryKeyAnnotation extends FieldAnnotation {
  const PrimaryKeyAnnotation({String? columnName, Type? columnType}) : super(columnName: columnName, columnType: columnType, nullable: false);
}
