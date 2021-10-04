import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_metadata/field_metadata.dart';
import 'package:orm_framework/src/orm_metadata/ignore_metadata.dart';
import 'package:orm_framework/src/orm_metadata/primary_key_metadata.dart';

import 'gender.dart';

@EntityMetadata("PERSONS")
class Person {
  int _instanceNumber = 0;

  @PrimaryKeyMetadata()
  late String id;
  late String name;
  late String firstName;
  @FieldMetadata("BDate")
  late DateTime birthDate;
  late Gender gender;

  @IgnoreMetadata()
  int get instanceNumber {
    return _instanceNumber++;
  }
}
