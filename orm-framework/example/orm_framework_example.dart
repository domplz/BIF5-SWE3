import 'package:orm_framework/orm_framework.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';
import 'dart:io';

import 'models/class.dart';
import 'models/gender.dart';
import 'models/teacher.dart';

void main() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  Orm.database = sqlite3.open("test.sqlite");

  var demo = OrmDemo();
  demo.showInsert();
  demo.showSelect();
  demo.showWithForeignKey();
  demo.showWithForeignKeyList();

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

    String teachesClasses = "";
    for (var teachesClass in t.classes) {
      teachesClasses += teachesClass.name + "; ";
    }
  }
}
