import 'package:orm_framework/src/annotations/primarykey_annotation.dart';
import 'package:orm_framework/src/orm.dart';
import 'package:test/test.dart';

void main() {
  group('Test Orm Cache', () {
    setUp(() {});

    test('Search Cache', () {

      var cache = <Object>[
        TestClass("test"),
        TestClass("test2"),
      ];

      expect(Orm.searchCache(TestClass, "test", cache), equals(cache[0]));
      expect(Orm.searchCache(TestClass, "test2", cache), equals(cache[1]));
      expect(Orm.searchCache(TestClass, "asdf", cache), equals(null));
    });
    test('Search Cache (empty cache does not throw)', () {
      expect(Orm.searchCache(TestClass, "test", null), equals(null));
      expect(Orm.searchCache(TestClass, "test", <Object>[]), equals(null));
    });

    
    test('Search Cache (right PK but wrong type)', () {

      var cache = <Object>[
        TestClass("test"),
        TestClass2("test2"),
      ];

      expect(Orm.searchCache(String, "test", cache), equals(null));
      expect(Orm.searchCache(TestClass2, "test", cache), equals(null));
      expect(Orm.searchCache(TestClass, "test2", cache), equals(null));
    });
  });
}

class TestClass {
  @PrimaryKeyAnnotation()
  String test;
  TestClass(this.test);
}

class TestClass2 extends TestClass {
  TestClass2(String test): super(test);
}