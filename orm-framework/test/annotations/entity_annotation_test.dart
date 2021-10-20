import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('Test EntityAnnotation', () {
    setUp(() {});

    test('TableName to be "TestClass"', () {
      var entity = Orm.getEntity(TestClass);

      expect(entity.tableName, equals("TestClasses"));
    });

    test('TableName to be the class name', () {
      var entity = Orm.getEntity(TestClassWithoutAnnotation);

      expect(entity.tableName, equals("TestClassWithoutAnnotation".toUpperCase()));
    });
  });
}

@EntityAnnotation(tableName: "TestClasses")
class TestClass {
  String test;
  TestClass(this.test);
}

class TestClassWithoutAnnotation {
  String test;
  TestClassWithoutAnnotation(this.test);
}
