import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

import 'gender.dart';

@EntityAnnotation(tableName: "PERSONS")
class Person {
  int _instanceNumber = 0;

  @PrimaryKeyAnnotation()
  late String id;
  late String name;
  late String firstName;
  @FieldAnnotation(columnName: "BDate")
  late DateTime birthDate;
  @FieldAnnotation(columnType: int)
  late Gender gender;

  @IgnoreAnnotation()
  int get instanceNumber {
    return _instanceNumber++;
  }
}
