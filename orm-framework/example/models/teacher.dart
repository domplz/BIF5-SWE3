import 'class.dart';
import 'course.dart';
import 'person.dart';

class Teacher extends Person {
  late int salary;
  late DateTime hireDate;
  late List<Class> classes;
  late List<Course> courses;
}