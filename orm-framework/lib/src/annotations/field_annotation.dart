/// Field annotations used on property level to provide metadata for the sql columns.
class FieldAnnotation {
  const FieldAnnotation({this.columnName, this.columnType, this.nullable});

  /// Gets or sets the column name of the sql column.
  final String? columnName;

  /// Gets or sets the column type of the sql column.
  final Type? columnType;

  /// Gets or sets whether the column is nullable.
  final bool? nullable;
}
