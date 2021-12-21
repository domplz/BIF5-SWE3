<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Simple Object Relational Mapper (ORM) implemented for BIF-5 SWE3 using Dart and SQLite.

# Features

## Selecting entities
```dart
    var testEntities = Orm.getAll<TestEntity>();
    var testEntityById = Orm.get<TestEntity>("idValue");
```

## Saving and creating entities

```dart
    testEntityById.value1 = "updated";
    Orm.save(testEntityById);

    var newEntity = TestEntity();
    Orm.save(newEntity);
```

## Deleting entities

```dart
    Orm.delete(newEntity);
```

## Fluid Querying Language

The framework supports a fluid querying language.

```dart
    // simple query using equals
    Orm.from<TestEntity>().equals("firstColumn", "value1", false).and().equals("secondColumn", "Value2", true).toList();

    // more complicated queries
    var useGroupReturnAliceAndBernard = Orm.from<TestEntity>()
        .beginGroup()
        .equals("firstColumn", "value1", false)
        .and()
        .equals("secondColumn", "Value2", true)
        .endGroup()
        .or()
        .beginGroup()
        .equals("firstColumn", "value3", false)
        .and()
        .equals("secondColumn", "Value4", true)
        .endGroup()
        .toList();
```

You can find more examples in the `/example` folder!

## Select by custom query

```dart
    String sql = "SELECT * FROM TESTENTITIES WHERE FIRSTCOLUMN = 'value1'";
    List<TestEntity> selectBySql = Orm.fromSql<TestEntity>(sql);
```

## Caching

Provide a `Cache` instance to support caching in your application.
There are two caching implementations provided by default:
- DefaultCache (no change tracking)
- TrackingCache (supports change tracking)

```dart
    // use default cache without change tracking
    Orm.cache = DefaultCache();

    // OR
    // use TrackingCache with change tracking
    Orm.cache = TrackingCache();
```

## Locking

Provide a `Locking` instance to support Locking in your application.
By default there is a DbLocking implementation included in the framework

```dart
    // enable database locking
    Orm.locking = DbLocking(sessionKeyParam: "SessionKeyForLocking", lockTableNameParam: "lockingTableName");

    // lock object
    var testEntityById = Orm.get<TestEntity>("idValue");
    Orm.lock(testEntityById);

    // release object again
    Orm.lock(testEntityById);
```

## Creating simple tables

You can create simple tables using the framework's `ensureTableCreated<T>()` method.

### Caution:
- If tables already exist, they will not be modified or overwritten!
- The entity must hava a primary key defined!
- The `ensureTableCreated<T>()` method does not support creating tables with foreign keys!

```dart
    // create simple table in db
    Orm.ensureTableCreated<SimpleEntity>();

```
## Deleting tables

Tables can be deleted by using the frameworks `ensureTableDeleted<T>()` method.

### Caution:
- Deleting does not handle foreign keys or other constraints!

```dart
    // delete table
    Orm.ensureTableDeleted<SimpleEntity>();

```


# Getting started

Install dart: [Get the Dart SDK](https://dart.dev/get-dart)

Import the framework in your project

```dart
    import 'package:orm_framework/orm_framework.dart';
```

Establish the connection to the SQLite database.
This code shows, how to connect to a SQLite database on windows

Locate the sqlite3.dll
```dart
    // locate the SQLite.dll
    DynamicLibrary _openOnWindows() {
        final libraryNextToScript = File('${pathToSqliteDll}\\sqlite3.dll');
        return DynamicLibrary.open(libraryNextToScript.path);
    }
```

Connect to the database
```dart
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
    Orm.database = sqlite3.open("test.sqlite");
```

Dispose the database after use.
```dart
    Orm.database.dispose();
```

# Usage

For detailed usage, view the `/example` folder!

# Run example code

Install dart: [Get the Dart SDK](https://dart.dev/get-dart)

Type the following commands in your terminal:

## Change to the "orm-framework"-folder
```
    cd .\orm-framework\
```

## Install packages
```
    dart pub get
```

## Run "orm_framework_example.dart" file
```
    dart run .\example\orm_framework_example.dart
```