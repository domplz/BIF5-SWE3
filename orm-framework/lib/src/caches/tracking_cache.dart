import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/caches/cache.dart';
import 'package:orm_framework/src/caches/default_cache.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

class TrackingCache extends DefaultCache implements Cache {
  final Map<Type, Map<Object, String>> _hashes = <Type, Map<Object, String>>{};

  Map<Object, String> _getHash(type) {
    if (_hashes.containsKey(type)) {
      return _hashes[type]!;
    }

    var hash = <Object, String>{};
    _hashes[type] = hash;

    return hash;
  }

  String _computeHash(Object object) {
    String hash = "";
    for (OrmField field in Orm.getEntity(object).internals) {
      // maybe nullcheck field.getValue() for null, but its not nullable.
      Object? fieldValue = field.getValue(object);

      if (fieldValue != null) {
        if (field.isForeignKey) {
          hash += "${field.columnName}=${Orm.getEntity(object).primaryKey.getValue(fieldValue).toString()};";
        } else {
          hash += "${field.columnName}=${fieldValue.toString()};";
        }
      }
    }

    for (OrmField field in Orm.getEntity(object).externals) {
      List<Object>? externalList = field.getValue(object) as List<Object>?;

      if (externalList != null && externalList.isNotEmpty) {
        hash += "${field.columnName}=";

        for (var element in externalList) {
          hash += "${Orm.getEntity(element).primaryKey.getValue(element)},";
        }

        hash += ";";
      }
    }

    List<int> bytes = utf8.encode(hash);
    return sha256.convert(bytes).toString();
  }

  @override
  void put(Object object) {
    Object? pkValue = Orm.getEntity(object).primaryKey.getValue(object);
    if (pkValue != null) {
      super.put(object);

      var hash = _getHash(object.runtimeType);
      hash[pkValue] = _computeHash(object);
    }
  }

  @override
  void remove(Object object) {
    super.remove(object);

    var hash = _getHash(object.runtimeType);
    hash.remove(Orm.getEntity(object).primaryKey.getValue(object));
  }

  @override
  bool hasChanged(Object object) {
    var hash = _getHash(object.runtimeType);
    Object? primaryKey = Orm.getEntity(object).primaryKey.getValue(object);

    if (hash.containsKey(primaryKey)) {
      return hash[primaryKey] != _computeHash(object);
    }

    return true;
  }
}
