import 'package:orm_framework/src/annotations/field_annotation.dart';

class ForeignKeyAnnotation extends FieldAnnotation {
  const ForeignKeyAnnotation({String? columnName, Type? columnType, bool? nullable, this.assignmentTable, this.remoteColumnName})
      : super(columnName: columnName, columnType: columnType, nullable: nullable);

  final String? assignmentTable;
  final String? remoteColumnName;
}
