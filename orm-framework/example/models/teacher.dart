import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';

import 'class.dart';
import 'course.dart';
import 'person.dart';

@EntityMetadata("CLASSES")
class Teacher extends Person {
  late int salary;
  late DateTime hireDate;
  late List<Class> classes;
  late List<Course> courses;
}