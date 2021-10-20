import 'dart:mirrors';

import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmField constructor', () {
    OrmField? fieldInstance;
    setUp(() {
      fieldInstance = OrmField(OrmEntity(TestClass), reflectClass(TestClass).declarations.values.first as VariableMirror, TestClass, "TestClass", TestClass, false, false, false);
    });

    test('To be not null', () {
      expect(fieldInstance, isNotNull);
    });
  });
}

@EntityAnnotation(tableName: "TestClass")
class TestClass {
  String test;
  TestClass(this.test);
}
