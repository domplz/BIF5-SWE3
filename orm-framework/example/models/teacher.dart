import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_metadata/field_metadata.dart';
import 'package:orm_framework/src/orm_metadata/foreign_key_metadata.dart';

import 'class.dart';
import 'course.dart';
import 'person.dart';

@EntityMetadata("CLASSES")
class Teacher extends Person {
  late int salary;
  @FieldMetadata("HDATE")
  late DateTime hireDate;
  @ForeignKeyMetadata("KTEACHER")
  late List<Class> classes;
  @ForeignKeyMetadata("KTEACHER")
  late List<Course> courses;
}
