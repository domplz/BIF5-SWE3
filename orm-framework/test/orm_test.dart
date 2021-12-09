import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';
import 'package:orm_framework/src/orm.dart';
import 'package:test/test.dart';

void main() {
  group('Test Orm getEntity', () {
    setUp(() {});

    test('With Type', () {
      expect(Orm.getEntity(TestClass), isNotNull);
    });
    test('With Instance', () {
      expect(Orm.getEntity(TestClass.withArguments("testClass", 123)), isNotNull);
    });
  });

  group('Test Orm CreateRowFromResult', () {
    setUp(() {});

    test('With full result map', () {
      var resultMap = <String, dynamic>{
        "TEST": "TestProperty",
        "ALSOTEST": 321,
      };

      var object = Orm.createObjectFromRow(TestClass, resultMap, null) as TestClass;
      expect(object.runtimeType, equals(TestClass));
      expect(object.test, equals("TestProperty"));
      expect(object.alsoTest, equals(321));
    });

    test('With null values result map', () {
      var resultMap = <String, dynamic>{
        "TEST": null,
        "ALSOTEST": null,
      };

      var object = Orm.createObjectFromRow(TestClass, resultMap, null) as TestClass;
      expect(object.runtimeType, equals(TestClass));
      expect(object.test, isEmpty);
      expect(object.alsoTest, equals(0));
    });

    test('With enums as INT', () {
      var resultMap = <String, dynamic>{
        "ID": "NiceIdMan",
        "ENUMVALUE": 1,
      };

      var object = Orm.createObjectFromRow(TestClassWithEnum, resultMap, null) as TestClassWithEnum;
      expect(object.runtimeType, equals(TestClassWithEnum));

      // cannot do the following, as creation with reflection does something weired with it
      // expect((object as TestClassWithEnum).enumValue, equals(TestEnum.valueTwo));
      expect(object.enumValue?.index, equals(TestEnum.valueTwo.index));
      expect(object.enumValue?.runtimeType, equals(TestEnum.valueTwo.runtimeType));
      expect(object.enumValue?.toString(), equals(TestEnum.valueTwo.toString()));
    });

    test('With enums as NULL', () {
      var resultMap = <String, dynamic>{
        "ID": "NiceIdMan",
        "ENUMVALUE": null,
      };

      var object = Orm.createObjectFromRow(TestClassWithEnum, resultMap, null) as TestClassWithEnum;
      expect(object.runtimeType, equals(TestClassWithEnum));

      expect(object.enumValue, equals(null));
      expect(object.enumValue?.index, equals(null));
      expect(object.enumValue?.runtimeType, equals(null));
      expect(object.enumValue?.toString(), equals(null));
    });

    test('With enums as STRING', () {
      var resultMap = <String, dynamic>{
        "ID": "NiceIdMan",
        "ENUMVALUE": "valueTwo",
      };

      var object = Orm.createObjectFromRow(TestClassWithEnumAsString, resultMap, null) as TestClassWithEnumAsString;
      expect(object.runtimeType, equals(TestClassWithEnumAsString));

      // cannot do the following, as creation with reflection does something weired with it
      // expect(object.enumValue, equals(TestEnum.valueTwo));
      expect(object.enumValue?.index, equals(TestEnum.valueTwo.index));
      expect(object.enumValue?.runtimeType, equals(TestEnum.valueTwo.runtimeType));
      expect(object.enumValue?.toString(), equals(TestEnum.valueTwo.toString()));
    });
  });
}

@EntityAnnotation(tableName: "TestClass")
class TestClass {
  @PrimaryKeyAnnotation()
  late String test;
  late int alsoTest;

  TestClass();
  TestClass.withArguments(this.test, this.alsoTest);
}

class TestClassWithEnum {
  @PrimaryKeyAnnotation()
  late String id;
  @FieldAnnotation(columnName: "enumValue", columnType: int, nullable: true)
  TestEnum? enumValue;
}

class TestClassWithEnumAsString {
  @PrimaryKeyAnnotation()
  late String id;
  @FieldAnnotation(columnName: "enumValue", columnType: String, nullable: true)
  TestEnum? enumValue;
}

enum TestEnum {
  valueOne,
  valueTwo,
  valueThree,
}
