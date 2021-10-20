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
      
      var object = Orm.createObjectFromRow(TestClass, resultMap, null);
      expect(object.runtimeType, equals(TestClass));
      expect((object as TestClass).test, equals("TestProperty"));
      expect((object as TestClass).alsoTest, equals(321));
    });

    test('With null values result map', () {
      var resultMap = <String, dynamic>{
        "TEST": null,
        "ALSOTEST": null,
      };
      
      var object = Orm.createObjectFromRow(TestClass, resultMap, null);
      expect(object.runtimeType, equals(TestClass));
      expect((object as TestClass).test, isEmpty);
      expect((object as TestClass).alsoTest, equals(0));
    });

    
    test('With enums as INT', () {
      var resultMap = <String, dynamic>{
        "ID": "NiceIdMan",
        "ENUMVALUE": 1,
      };
      
      var object = Orm.createObjectFromRow(TestClassWithEnum, resultMap, null);
      expect(object.runtimeType, equals(TestClassWithEnum));
      
      // cannot do the following, as creation with reflection does something weired with it
      // expect((object as TestClassWithEnum).enumValue, equals(TestEnum.valueTwo));
      expect((object as TestClassWithEnum).enumValue?.index, equals(TestEnum.valueTwo.index));
      expect((object as TestClassWithEnum).enumValue?.runtimeType, equals(TestEnum.valueTwo.runtimeType));
      expect((object as TestClassWithEnum).enumValue?.toString(), equals(TestEnum.valueTwo.toString()));
    });
  });

}

@EntityAnnotation("TestClass")
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
  @FieldAnnotation("enumValue", int, true)
  TestEnum? enumValue;
}

enum TestEnum {
  valueOne,
  valueTwo, 
  valueThree,
}
