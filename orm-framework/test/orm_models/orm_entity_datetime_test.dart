import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmEntity constructor with date fields', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('With DateTime-Type', () {
      expect(OrmEntity(TestClass), isNotNull);
      expect(OrmEntity(TestClass).fields[0].columnType, DateTime);
    });
  });
}

@EntityAnnotation(tableName: "TestClass")
class TestClass {
  @FieldAnnotation(columnName: "TDATE")
  DateTime test;
  TestClass(this.test);
}
