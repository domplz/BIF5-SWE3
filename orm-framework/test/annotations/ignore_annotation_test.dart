import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('Test PrimaryKeyAnnotation', () {
    setUp(() {});

    test('Expect to work when all parameters are set', () {
      var entity = Orm.getEntity(TestClass);

      expect(entity.fields.length, equals(0));
    });
  });
}

class TestClass {
  @IgnoreAnnotation()
  String test;
  TestClass(this.test);
}
