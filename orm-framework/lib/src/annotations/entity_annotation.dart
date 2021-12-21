// https://medium.com/swlh/dart-annotations-a-simple-intro-to-reflection-c654275cc967

/// Entity Annotation used on class level to provide metadata for the sql table.
class EntityAnnotation {
  const EntityAnnotation({this.tableName});

  /// Gets or sets the table name used in sql.
  final String? tableName;
}
