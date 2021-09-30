class FieldMetadata {
  const FieldMetadata([this.columnName, this.columnType = String, this.nullable = false]);

  final String? columnName;
  final Type? columnType;
  final bool? nullable;
}