import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

import 'gender.dart';

@EntityAnnotation(tableName: "PERSONS")
abstract class Person {
  static int _instanceCounter = 0;
  @IgnoreAnnotation()
  late int instanceNumber = _instanceCounter++;

  @PrimaryKeyAnnotation()
  late String id;
  late String name;
  late String firstName;
  @FieldAnnotation(columnName: "BDate")
  late DateTime birthDate;
  @FieldAnnotation(columnType: int)
  late Gender gender;
}
