import 'package:orm_framework/src/annotations/field_annotation.dart';

/// The foreign key field annotations used on property level to provide metadata for foreign key sql columns.
class ForeignKeyAnnotation extends FieldAnnotation {
  const ForeignKeyAnnotation(
      {String? columnName, Type? columnType, bool? nullable, this.assignmentTable, this.remoteColumnName})
      : super(columnName: columnName, columnType: columnType, nullable: nullable);

  /// Gets or sets the name of the assignment table.
  final String? assignmentTable;

  /// Gets or sets the column name of the remote column on the assignment table.
  final String? remoteColumnName;
}
