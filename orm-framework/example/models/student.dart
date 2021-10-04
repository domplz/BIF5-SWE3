import 'package:orm_framework/src/annotations/entity_annotation.dart';

import 'person.dart';

@EntityAnnotation("STUDENTS")
class Student extends Person {
  late int grade;
}
