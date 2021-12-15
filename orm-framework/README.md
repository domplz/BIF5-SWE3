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

Simple Object Relational Mapper (ORM) implemented for BIF-5 SWE3 using Dart.

## Features

# Selecting entities
```dart
    var testEntities = Orm.getAll<TestEntity>();
    var testEntityById = Orm.get<TestEntity>("idValue");
```

# Saving and creating entities

```dart
    testEntityById.value1 = "updated";
    Orm.save(testEntityById);

    var newEntity = TestEntity();
    Orm.save(newEntity);
```

# Deleting entities

```dart
    Orm.delete(newEntity);
```

# Caching

Provide a ```Cache``` instance to support caching in your application.
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

# Locking

Provide a ```Locking``` instance to support Locking in your application.
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

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
