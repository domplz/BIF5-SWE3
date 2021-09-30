import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';

import 'teacher.dart';

@EntityMetadata("COURSES")
class Course {
  late String id;
  late String name;
  late Teacher teacher;
}