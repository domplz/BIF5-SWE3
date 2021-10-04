import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';

import 'class.dart';
import 'course.dart';
import 'person.dart';

@EntityAnnotation("CLASSES")
class Teacher extends Person {
  late int salary;
  @FieldAnnotation("HDATE")
  late DateTime hireDate;
  @ForeignKeyAnnotation("KTEACHER")
  late List<Class> classes;
  @ForeignKeyAnnotation("KTEACHER")
  late List<Course> courses;
}
