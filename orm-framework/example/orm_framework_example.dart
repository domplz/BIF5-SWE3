import 'package:orm_framework/orm_framework.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';
import 'dart:io';

import 'models/gender.dart';
import 'models/teacher.dart';

void main() {
  OrmDemo().show();
}

class OrmDemo {
  show() {
    open.overrideFor(OperatingSystem.windows, _openOnWindows);

    Orm.database = sqlite3.open("test.sqlite");

    Teacher t = Teacher();
    t.hireDate = DateTime(2010, 11, 1);
    t.salary = 3000;
    t.birthDate = DateTime(2987, 1, 14);
    t.firstName = "Seppi";
    t.gender = Gender.male;
    t.id = "t.1";
    t.name = "Forcher";

    Orm.save(t);

    var teachers = Orm.getAll<Teacher>();
    // Use the database
    Orm.database.dispose();
  }

  DynamicLibrary _openOnWindows() {
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
    return DynamicLibrary.open(libraryNextToScript.path);
  }
}
