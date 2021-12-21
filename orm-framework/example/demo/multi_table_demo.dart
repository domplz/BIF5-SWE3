import 'package:orm_framework/src/cache/default_cache.dart';
import 'package:orm_framework/src/locking/db_locking.dart';
import 'package:orm_framework/src/locking/object_locked_exception.dart';
import 'package:orm_framework/src/orm.dart';
import 'package:uuid/uuid.dart';

import '../models/car.dart';
import '../models/class.dart';
import '../models/course.dart';
import '../models/gender.dart';
import '../models/person.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import 'demo_base.dart';

class MultiTableDemo extends DemoBase {
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
    print("\nSHOWING CACHE FUNCTIONALITY");
    printSeperator();

    print("INSTANCES WITHOUT CACHE:");
    _showTeacherInstances();

    Orm.cache = DefaultCache();

    print("INSTANCES WITH CACHE:");
    _showTeacherInstances();
  }

  void withQuery() {
    print("\nSHOWING QUERYING FUNCTIONALITY");
    printSeperator();

    var aliceWithSurname =
        Orm.from<Student>().equals("firstname", "Alice", false).and().equals("name", "aalo", true).toList();
    print('Orm.from<Student>().equals("firstname", "Alice", false).and().equals("name", "aalo", true).toList();');
    printInstanceList(aliceWithSurname, ["id", "firstName", "name"]);

    var studentsWithGradGt1 = Orm.from<Student>().greaterThan("grade", 1).toList();
    print('Orm.from<Student>().greaterThan("grade", 1).toList();');
    printInstanceList(studentsWithGradGt1, ["id", "firstName", "name"]);

    var studentsWithGradLt2 = Orm.from<Student>().lessThan("grade", 2).toList();
    print('Orm.from<Student>().lessThan("grade", 2).toList();');
    printInstanceList(studentsWithGradLt2, ["id", "firstName", "name"]);

    var studentsWithGradGt1AndFirstNameAl =
        Orm.from<Student>().greaterThan("grade", 1).or().like("firstName", "al%").toList();
    print('Orm.from<Student>().greaterThan("grade", 1).or().like("firstName", "al%").toList();');
    printInstanceList(studentsWithGradGt1AndFirstNameAl, ["id", "firstName", "name"]);

    var personsNotAlice = Orm.from<Person>().not().equals("firstName", "alice", true).toList();
    print('Orm.from<Person>().not().equals("firstName", "alice", true).toList();');
    printInstanceList(personsNotAlice, ["id", "firstName", "name"]);

    var personInAliceOrSeppi = Orm.from<Person>().isIn("firstname", ["Alice", "Seppi"]).toList();
    print('Orm.from<Person>().isIn("firstname", ["Alice", "Seppi"]).toList();');
    printInstanceList(personInAliceOrSeppi, ["id", "firstName", "name"]);

    var personNotInAliceOrSeppi = Orm.from<Person>().not().isIn("firstname", ["Alice", "Seppi"]).toList();
    print('Orm.from<Person>().not().isIn("firstname", ["Alice", "Seppi"]).toList();');
    printInstanceList(personNotInAliceOrSeppi, ["id", "firstName", "name"]);

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
    print(
        'Orm.from<Person>().beginGroup().equals("firstname", "Alice", false).and().equals("name", "aalo", true).endGroup().or().beginGroup().equals("firstname", "Bernard", false).and().equals("name", "Bumblebee", true).endGroup().toList();');
    printInstanceList(useGroupReturnAliceAndBernard, ["id", "firstName", "name"]);

    var allPersons = Orm.from<Person>().toList();
    print('Orm.from<Person>().toList();');
    printInstanceList(allPersons, ["id", "firstName", "name"]);
  }

  void withSql() {
    print("\nSHOWING SELECT USING SQL:");
    printSeperator();

    String sql = "SELECT * FROM TEACHERS";
    var starFromTeacher = Orm.fromSql<Teacher>(sql);
    print(sql);
    printInstanceList(starFromTeacher, ["id", "firstName", "name"]);

    String sqlWithWhere = "SELECT * FROM STUDENTS WHERE FIRSTNAME = 'Alice'";
    var starFromStudentsWhereAlice = Orm.fromSql<Student>(sqlWithWhere);
    print(sqlWithWhere);
    printInstanceList(starFromStudentsWhereAlice, ["id", "firstName", "name"]);
  }

  void withLocking() {
    print("\nSHOWING LOCKING FUNCTIONALITY:");
    printSeperator();

    String sessionKey = Uuid().v4().toString();
    Orm.locking = DbLocking(sessionKeyParam: sessionKey);

    Teacher t = Orm.get<Teacher>("t.0");
    print("LOCK TEACHER:");
    Orm.lock(t);
    // lock again
    print("LOCK TEACHER AGAIN:");
    Orm.lock(t);

    // lock with another session
    print("CREATE DIFFERENT LOCKING SESSION:");
    Orm.locking = DbLocking();
    try {
      print("TRY LOCKING WITH DIFFERENT SESSION:");
      Orm.lock(t);
    } on ObjectLockedException catch (e) {
      // actually throws
      print("COULD NOT LOCK INSTANCE! Exception: " + e.toString());
    }

    print("CREATE LOCKING SESSION WITH OLD SESSION KEY:");
    Orm.locking = DbLocking(sessionKeyParam: sessionKey);

    print("RELEASE LOCK:");
    Orm.release(t);
  }

  void withCreateAndDropTable() {
    // ensure created table
    print("\nSHOWING CREATE TABLE FUNCTIONALITY:");
    printSeperator();

    Orm.ensureTableCreated<Car>();
    print("\nTABLE CAR CREATED:");

    print("\n INSERT & LOAD CAR");
    String carPK = "nice_id";

    var newCar = Car();
    newCar.id = carPK;
    newCar.name = "skoda fabia";
    newCar.productionDate = DateTime(2003, 11, 1);
    newCar.horsePower = 103;
    newCar.fuelConsumption = 5.5;

    Orm.save(newCar);
    var loadedCar = Orm.get<Car>(carPK);
    printInstance(loadedCar, ["id", "name", "productionDate", "horsePower", "fuelConsumption"]);

    Orm.ensureTableDeleted<Car>();
    print("\nTABLE CAR DELETED:");
  }

  void _showTeacherInstances() {
    for (int i = 0; i < 7; i++) {
      Teacher t = Orm.get<Teacher>("t.0");
      print("Object [ ${t.id} ] instance no. ${t.instanceNumber.toString()}");
    }
  }
}
