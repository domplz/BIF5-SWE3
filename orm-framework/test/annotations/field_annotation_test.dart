import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('Test FieldAnnotation', () {
    setUp(() {});

    test('Expect to work when all parameters are set', () {
      var entity = Orm.getEntity(TestClass);

      expect(entity.fields.first.columnName, equals("TestField"));
      expect(entity.fields.first.type, equals(String));
      expect(entity.fields.first.isNullable, equals(true));
      expect(entity.fields.first.isForeignKey, equals(false));
      expect(entity.fields.first.isPrimaryKey, equals(false));
    });

    test('Expect to work when no parameters are set', () {
      var entity = Orm.getEntity(TestClassWithoutParameters);

      expect(entity.fields.first.columnName, equals("test"));
      expect(entity.fields.first.type, equals(String));
      expect(entity.fields.first.isNullable, equals(false));
      expect(entity.fields.first.isForeignKey, equals(false));
      expect(entity.fields.first.isPrimaryKey, equals(false));
    });
  });
}

class TestClass {
  @FieldAnnotation("TestField", String, true)
  String test;
  TestClass(this.test);
}

class TestClassWithoutParameters {
  @FieldAnnotation()
  String test;
  TestClassWithoutParameters(this.test);
}
