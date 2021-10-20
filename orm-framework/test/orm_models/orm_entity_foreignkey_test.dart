import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:test/test.dart';

void main() {
  group('Test OrmEntity constructor with foreign key fields', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('With ForeignKey field', () {
      expect(OrmEntity(TestClass), isNotNull);

      // first internal is the id
      expect(OrmEntity(TestClass).internals[0].columnType, equals(int));
      expect(OrmEntity(TestClass).internals[0].isPrimaryKey, equals(true));
      expect(OrmEntity(TestClass).internals[0].isExternal, equals(false));
      expect(OrmEntity(TestClass).internals[0].isForeignKey, equals(false));
      expect(OrmEntity(TestClass).internals[0].isManyToMany, equals(false));
      expect(OrmEntity(TestClass).internals[0].isNullable, equals(false));
      expect(OrmEntity(TestClass).internals[0].assignmentTable, equals(null));
      expect(OrmEntity(TestClass).internals[0].remoteColumnName, equals(null));

      // first external is the fk
      expect(OrmEntity(TestClass).externals[0].columnType.toString(), equalsIgnoringCase("List<TestClass2>"));
      expect(OrmEntity(TestClass).externals[0].isPrimaryKey, equals(false));
      expect(OrmEntity(TestClass).externals[0].isExternal, equals(true));
      expect(OrmEntity(TestClass).externals[0].isForeignKey, equals(true));
      expect(OrmEntity(TestClass).externals[0].isManyToMany, equals(false));
      expect(OrmEntity(TestClass).externals[0].isNullable, equals(false));
      expect(OrmEntity(TestClass).externals[0].remoteColumnName, equals(null));
      expect(OrmEntity(TestClass).externals[0].assignmentTable, equals(null));

      // field1 is the PK, field2 is the FK
      expect(OrmEntity(TestClass).fields[0].columnName, equals("id1"));
      expect(OrmEntity(TestClass).fields[0].isPrimaryKey, equals(true));
      expect(OrmEntity(TestClass).fields[1].columnName, equals("id2"));
      expect(OrmEntity(TestClass).fields[1].isForeignKey, equals(true));
    });
  });
}

@EntityAnnotation(tableName: "TestClass")
class TestClass {
  @PrimaryKeyAnnotation()
  int id1;
  @ForeignKeyAnnotation(columnName: "id2")
  List<TestClass2> test2s;

  TestClass(this.id1, this.test2s);
}

class TestClass2 {
  @PrimaryKeyAnnotation()
  int id2;

  TestClass2(this.id2);
}
