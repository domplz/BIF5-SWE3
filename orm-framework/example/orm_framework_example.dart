import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/default_cache.dart';
import 'package:orm_framework/src/orm_models/db_locking.dart';
import 'package:orm_framework/src/orm_models/object_locked_exception.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'dart:ffi';
import 'dart:io';
import 'dart:mirrors';

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
  // demo.withCache();
  // demo.withQuery();
  // demo.withSql();
  // demo.withLocking();

  Orm.database.dispose();
}

DynamicLibrary _openOnWindows() {
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}

class OrmDemo {
  showInsert() {
    print("\nSHOWING INSERT TEACHER:");
    printSeperator();

    Teacher t = Teacher();
    t.hireDate = DateTime(2010, 11, 1);
    t.salary = 3000;
    t.birthDate = DateTime(2987, 1, 14);
    t.firstName = "John";
    t.gender = Gender.male;
    t.id = "t.1";
    t.name = "Doe";

    Orm.save(t);

    print("Inserted: ");
    printInstance(t, ["id", "firstName", "name"]);
  }

  showSelect() {
    print("\nSHOWING SELECT TEACHER:");
    printSeperator();

    print("SELECT ALL TEACHERS:");
    var teachers = Orm.getAll<Teacher>();
    printInstanceList(teachers, ["id", "firstName", "name"]);

    String teacherId = teachers[0].id;
    print("SELECT TEACHER FOR ID $teacherId:");
    var teacherForId = Orm.get<Teacher>(teacherId);
    printInstance(teacherForId, ["id", "firstName", "name"]);
  }

  showWithForeignKey() {
    print("\nSHOWING INSERT WITH FOREIGN KEY:");
    printSeperator();

    Teacher t = Orm.get<Teacher>("t.0");

    Class c = Class();
    c.id = "c.0";
    c.name = "SWE3";
    c.teacher = t;

    Orm.save(c);

    Class c2 = Orm.get<Class>("c.0");
    print("INSERTED CLASS:");
    printInstance(c2, ["id", "name", "teacher"]);
  }

  showWithForeignKeyList() {
    print("\nSHOWING INSERT WITH FOREIGN KEY LIST:");
    printSeperator();

    Teacher t = Orm.get<Teacher>("t.0");

    // add another class
    Class c = Class();
    c.id = "c.1";
    c.name = "INN3";
    c.teacher = t;

    Orm.save(c);

    t = Orm.get<Teacher>("t.0");
    print("INSERTED CLASS:");
    printInstance(c, ["id", "name", "teacher"]);

    Teacher fkTeacher = Orm.get<Teacher>(c.teacher.id);
    print("FK TEACHER: ");
    printInstance(fkTeacher, ["id", "firstName", "name", "classes"]);
  }

  showWithMToN() {
    print("\nSHOWING INSERT WITH M TO N:");
    printSeperator();

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
    print("COURSE WITH STUDENTS: ");
    printInstance(courseWithStudents, ["id", "name", "students"]);
  }

  void createAndDelete() {
    print("\nSHOWING CREATE AND DELETE");
    printSeperator();

    String teacherId = Uuid().v4().toString();
    Teacher t = Teacher();
    t.hireDate = DateTime(2010, 11, 1);
    t.salary = 3000;
    t.birthDate = DateTime(2987, 1, 14);
    t.firstName = "John";
    t.gender = Gender.male;
    t.id = teacherId;
    t.name = "Doe";

    Orm.save(t);

    var createdTeacher = Orm.get<Teacher>(teacherId);
    print("CREATED TEACHER:");
    printInstance(createdTeacher, ["id", "firstName", "name", "classes"]);

    print("DELETE TEACHER:");
    Orm.delete(t);
    try {
      print("TRY TO LOAD DELETED TEACHER:");
      Orm.get<Teacher>(teacherId);
    } catch (e) {
      print("Could not get teacher with id $teacherId. Exception: " + e.toString());
    }
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

  void withLocking() {
    String sessionKey = Uuid().v4().toString();
    Orm.locking = DbLocking(sessionKeyParam: sessionKey);

    Teacher t = Orm.get<Teacher>("t.0");
    Orm.lock(t);
    // lock again
    Orm.lock(t);

    // lock with another session
    Orm.locking = DbLocking();
    try {
      Orm.lock(t);
    } on ObjectLockedException catch (e) {
      // actually throws
      String error = e.toString();
    }

    Orm.locking = DbLocking(sessionKeyParam: sessionKey);
    Orm.release(t);
  }

  void _showInstances() {
    for (int i = 0; i < 7; i++) {
      Teacher t = Orm.get<Teacher>("t.0");
      print("Object [ ${t.id} ] instance no. ${t.instanceNumber.toString()}");
    }
  }

  void printInstance(Object instance, List<String> fieldsToPrint) {
    print("Instance: ${instance.runtimeType}");
    for (var item in fieldsToPrint) {
      InstanceMirror instanceMirror = reflect(instance);
      print("$item: ${instanceMirror.getField(Symbol(item)).reflectee}");
    }
  }

  void printInstanceList(List<Object> instances, List<String> fieldsToPrint) {
    int index = 0;
    for (var item in instances) {
      print("Element $index:");
      printInstance(item, fieldsToPrint);
      printSeperator();
      index++;
    }
  }

  void printSeperator() {
    print("------------------------------------------");
  }
}
