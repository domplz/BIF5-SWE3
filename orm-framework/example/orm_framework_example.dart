import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/default_cache.dart';
import 'package:orm_framework/src/tracking_cache.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'dart:ffi';
import 'dart:io';

import 'models/class.dart';
import 'models/course.dart';
import 'models/gender.dart';
import 'models/person.dart';
import 'models/student.dart';
import 'models/teacher.dart';

void main() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  Orm.database = sqlite3.open("test.sqlite");

  // Orm.cache = TrackingCache();
  // Orm.cache = DefaultCache();

  var demo = OrmDemo();
  demo.showInsert();
  demo.showSelect();
  demo.showWithForeignKey();
  demo.showWithForeignKeyList();
  demo.showWithMToN();
  demo.createAndDelete();
  demo.withCache();
  demo.withQuery();
  demo.withSql();

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

  showWithMToN() {
    Course course = Course();
    course.id = "x.0";
    course.name = "Demons 1";
    course.teacher = Orm.get<Teacher>("t.0");

    Student student1 = Student();
    student1.id = "s.0";
    student1.name = "Aalo";
    student1.firstName = "Alice";
    student1.gender = Gender.female;
    student1.birthDate = DateTime(1990, 1, 12);
    student1.grade = 1;

    Orm.save(student1);

    course.students.add(student1);

    Student student2 = Student();
    student2.id = "s.1";
    student2.name = "Bumblebee";
    student2.firstName = "Bernard";
    student2.gender = Gender.male;
    student2.birthDate = DateTime(1991, 9, 23);
    student2.grade = 2;

    Orm.save(student2);

    course.students.add(student2);

    Orm.save(course);

    Course courseWithStudents = Orm.get<Course>("x.0");
  }

  void createAndDelete() {
    Teacher t = Teacher();
    t.hireDate = DateTime(2010, 11, 1);
    t.salary = 3000;
    t.birthDate = DateTime(2987, 1, 14);
    t.firstName = "Seppi";
    t.gender = Gender.male;
    t.id = Uuid().v4().toString();
    t.name = "Forcher";

    Orm.save(t);

    Orm.delete(t);
  }

  void withCache() {
    _showInstances();

    Orm.cache = DefaultCache();

    _showInstances();
  }

  void withQuery() {
    var aliceWithSurname =
        Orm.from<Student>().equals("firstname", "Alice", false).and().equals("name", "aalo", true).toList();

    var studentsWithGradGt1 = Orm.from<Student>().greaterThan("grade", 1).toList();
    var studentsWithGradLt2 = Orm.from<Student>().lessThan("grade", 2).toList();
    var studentsWithGradGt1AndFirstNameAl =
        Orm.from<Student>().greaterThan("grade", 1).or().like("firstName", "al%").toList();

    var personsNotAlice = Orm.from<Person>().not().equals("firstName", "alice", true).toList();
    var personInAliceOrSeppi = Orm.from<Person>().isIn("firstname", ["Alice", "Seppi"]).toList();
    var personNotInAliceOrSeppi = Orm.from<Person>().not().isIn("firstname", ["Alice", "Seppi"]).toList();

    var useGroupReturnAliceAndBernard = Orm.from<Person>()
        .beginGroup()
        .equals("firstname", "Alice", false)
        .and()
        .equals("name", "aalo", true)
        .endGroup()
        .or()
        .beginGroup()
        .equals("firstname", "Bernard", false)
        .and()
        .equals("name", "Bumblebee", true)
        .endGroup()
        .toList();

    var allPersons = Orm.from<Person>().toList();
  }

  void withSql() {
    String sql = "SELECT * FROM TEACHERS";

    var starFromTeacher = Orm.fromSql<Teacher>(sql);

    String sqlWithWhere = "SELECT * FROM STUDENTS WHERE FIRSTNAME = 'Alice'";
    var starFromStudentsWhereAlice = Orm.fromSql<Student>(sqlWithWhere);
  }

  void _showInstances() {
    for (int i = 0; i < 7; i++) {
      Teacher t = Orm.get<Teacher>("t.0");
      print("Object [ ${t.id} ] instance no. ${t.instanceNumber.toString()}");
    }
  }
}
