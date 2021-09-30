import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';

import 'gender.dart';

@EntityMetadata("PERSONS")
class Person {
  late String id;
  late String name;
  late String firstName;
  late DateTime birthDate;
  late Gender gender;
}