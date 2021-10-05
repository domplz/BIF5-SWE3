import 'package:collection/src/iterable_extensions.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmEntity constructor with inheritance', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('To have the defined fields', () {
      var entity = OrmEntity(InheritedClass);
      expect(entity, isNotNull);
      expect(entity.fields.length, equals(2));
      expect(entity.fields.firstWhereOrNull((f) => f.columnName == "baseProperty")?.columnName, "baseProperty");
      expect(entity.fields.firstWhereOrNull((f) => f.columnName == "inheritedClassProperty")?.columnName, "inheritedClassProperty");
    });
  });
}

class BaseClass {
  String baseProperty;
  BaseClass(this.baseProperty);
}

class InheritedClass extends BaseClass {
  String inheritedClassProperty;
  InheritedClass(this.inheritedClassProperty, String baseProperty) : super (baseProperty);
}