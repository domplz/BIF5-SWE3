import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

import 'student.dart';
import 'teacher.dart';

@EntityAnnotation(tableName: "COURSES")
class Course {
  @PrimaryKeyAnnotation()
  late String id;
  late String name;
  @ForeignKeyAnnotation(columnName: "KTEACHER")
  late Teacher teacher;
  @ForeignKeyAnnotation(columnName: "KCOURSE", assignmentTable: "STUDENT_COURSES", remoteColumnName: "KSTUDENT")
  late List<Student> students;
}
