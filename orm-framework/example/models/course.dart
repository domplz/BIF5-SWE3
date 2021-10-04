import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_metadata/foreign_key_metadata.dart';

import 'teacher.dart';

@EntityMetadata("COURSES")
class Course {
  late String id;
  late String name;
  @ForeignKeyMetadata("KTEACHER")
  late Teacher teacher;
}
