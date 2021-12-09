import 'package:orm_framework/orm_framework.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';
import 'dart:io';

import 'demo/multi_table_demo.dart';

void main() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  Orm.database = sqlite3.open("test.sqlite");

  var multiTableDemo = MultiTableDemo();
  multiTableDemo.showInsert();
  multiTableDemo.showSelect();
  multiTableDemo.showWithForeignKey();
  multiTableDemo.showWithForeignKeyList();
  multiTableDemo.showWithMToN();
  multiTableDemo.createAndDelete();
  multiTableDemo.withCache();
  multiTableDemo.withQuery();
  multiTableDemo.withSql();
  multiTableDemo.withLocking();

  Orm.database.dispose();
}

DynamicLibrary _openOnWindows() {
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}
