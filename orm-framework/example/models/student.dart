import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';

import 'person.dart';

@EntityMetadata("CLASSES")
class Student extends Person{
  late int grade;
}