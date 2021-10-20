class FieldAnnotation {
  const FieldAnnotation({this.columnName, this.columnType, this.nullable});

  final String? columnName;
  final Type? columnType;
  final bool? nullable;
}
