import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

import 'teacher.dart';

@EntityAnnotation(tableName: "CLASSES")
class Class {
  @PrimaryKeyAnnotation()
  late String id;
  late String name;
  @ForeignKeyAnnotation(remoteColumnName: "KTEACHER")
  late Teacher teacher;
}
