import 'package:orm_framework/orm_framework.dart';

import 'models/course.dart';
import 'models/person.dart';

void main() {
  var entity = Orm.getEntity(Course());
  var entity2 = Orm.getEntity(Person);
}
