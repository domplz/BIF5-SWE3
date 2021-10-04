import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

import 'teacher.dart';

@EntityAnnotation("COURSES")
class Course {
  @PrimaryKeyAnnotation()
  late String id;
  late String name;
  @ForeignKeyAnnotation("KTEACHER")
  late Teacher teacher;
}
