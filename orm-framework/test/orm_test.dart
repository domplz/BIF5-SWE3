import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/orm.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmField constructor', () {
    setUp(() {});

    test('With Type', () {
      expect(Orm.getEntity(TestClass), isNotNull);
    });
    test('With Instance', () {
      expect(Orm.getEntity(TestClass("testClass")), isNotNull);
    });
  });
}

@EntityAnnotation("TestClass")
class TestClass {
  String test;
  TestClass(this.test);
}
