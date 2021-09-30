import 'package:orm_framework/orm_framework.dart';

import 'models/class.dart';
import 'models/course.dart';

void main() {
  var entity = Orm.getEntity(Class());
  var entity2 = Orm.getEntity(Course());
}
