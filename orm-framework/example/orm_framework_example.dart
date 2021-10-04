import 'package:orm_framework/orm_framework.dart';

import 'models/class.dart';
import 'models/course.dart';
import 'models/person.dart';
import 'models/student.dart';
import 'models/teacher.dart';

void main() {
  var classEntity = Orm.getEntity(Class);
  var courseEntity = Orm.getEntity(Course());
  var personEntity = Orm.getEntity(Person);
  var studentEntity = Orm.getEntity(Student());
  var teacherEntity = Orm.getEntity(Teacher);
}
