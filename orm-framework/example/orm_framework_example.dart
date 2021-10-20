import 'package:orm_framework/orm_framework.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';
import 'dart:io';

import 'models/class.dart';
import 'models/course.dart';
import 'models/gender.dart';
import 'models/student.dart';
import 'models/teacher.dart';

void main() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  Orm.database = sqlite3.open("test.sqlite");

  var demo = OrmDemo();
  demo.showInsert();
  demo.showSelect();
  demo.showWithForeignKey();
  demo.showWithForeignKeyList();
  demo.showWithMToN();

  Orm.database.dispose();
}

DynamicLibrary _openOnWindows() {
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}

class OrmDemo {
  showInsert() {
    Teacher t = Teacher();
    t.hireDate = DateTime(2010, 11, 1);
    t.salary = 3000;
    t.birthDate = DateTime(2987, 1, 14);
    t.firstName = "Seppi";
    t.gender = Gender.male;
    t.id = "t.1";
    t.name = "Forcher";

    Orm.save(t);
  }

  showSelect() {
    var teachers = Orm.getAll<Teacher>();
    var teacherForId = Orm.get<Teacher>(teachers[0].id);
  }

  showWithForeignKey() {
    Teacher t = Orm.get<Teacher>("t.0");

    Class c = Class();
    c.id = "c.0";
    c.name = "SWE3";
    c.teacher = t;

    Orm.save(c);

    Class c2 = Orm.get<Class>("c.0");
  }

  showWithForeignKeyList() {
    Teacher t = Orm.get<Teacher>("t.0");

    // add another class
    Class c = Class();
    c.id = "c.1";
    c.name = "INN3";
    c.teacher = t;

    Orm.save(c);

    t = Orm.get<Teacher>("t.0");
  }

  showWithMToN(){
    Course c = Course();
    c.id = "x.0";
    c.name = "Demons 1";
    c.teacher = Orm.get<Teacher>("t.0");

    Student s1 = Student();
    s1.id = "s.0";
    s1.name = "Aalo";
    s1.firstName = "Alice";
    s1.gender = Gender.female;
    s1.birthDate = DateTime(1990, 1 , 12);
    s1.grade = 1;
    
    Orm.save(s1);

    c.students.add(s1);
    
    Student s2 = Student();
    s2.id = "s.1";
    s2.name = "Bumblebee";
    s2.firstName = "Bernard";
    s2.gender = Gender.male;
    s2.birthDate = DateTime(1991, 9 , 23);
    s2.grade = 2;
    
    Orm.save(s2);

    c.students.add(s2);

    Course courseWithStudents = Orm.get<Course>("x.0");
  }
}
