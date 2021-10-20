import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmEntity constructor', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('With Type', () {
      expect(OrmEntity(TestClass), isNotNull);
    });
  });
}

@EntityAnnotation(tableName: "TestClass")
class TestClass {
  String test;
  TestClass(this.test);
}
