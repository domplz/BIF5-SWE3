import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';

import 'teacher.dart';

@EntityMetadata("CLASSES")
class Class {
  late String id;
  late String name;
  late Teacher teacher;
}