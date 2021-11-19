import 'dart:collection';
import 'dart:mirrors';

import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'package:orm_framework/src/orm_models/query_operation.dart';

class Query<T> with IterableMixin<T> {
  final Query<T>? _previous;
  QueryOperation _operation = QueryOperation.noOperation;
  List<Object> _args = [];
  final List<T> _internalValues = [];

  @override
  Iterator<T> get iterator => _values.iterator;

  Query(this._previous);

  void _fill(Type type, List<Object>? localCache) {
    List<Query<T>> operations = [];

    Query<T>? query = this;
    while (query != null) {
      operations.insert(0, query);
      query = query._previous;
    }

    OrmEntity entity = Orm.getEntity(type);

    String sql = entity.getSql();
    List<String> parameters = [];
    String conj = " WHERE ";
    bool not = false;
    String opbrk = "";
    String clbrk = "";
    String op;

    OrmField field;

    for (Query<T> i in operations) {
      switch (i._operation) {
        case QueryOperation.or:
          if (conj != " WHERE ") {
            conj = " OR ";
          }
          break;
        case QueryOperation.not:
          not = true;
          break;
        case QueryOperation.beginGroup:
          opbrk += "(";
          break;
        case QueryOperation.endGroup:
          opbrk += ")";
          break;
        case QueryOperation.equals:
        case QueryOperation.like:
          field = entity.getFieldByName(i._args[0] as String);

          if (i._operation == QueryOperation.like) {
            op = (not ? " NOT LIKE " : " LIKE ");
          } else {
            op = (not ? " != " : " = ");
          }

          sql += clbrk + conj + opbrk;

          bool isIgnoreCase = i._args[2] as bool;
          if (isIgnoreCase) {
            sql += " LOWER(${field.columnName}) ";
          } else {
            sql += field.columnName;
          }

          sql += op;

          if (isIgnoreCase) {
            sql += " LOWER( ? ) ";
          } else {
            sql += " ? ";
          }

          String fieldValue = i._args[1] as String;
          if (isIgnoreCase) {
            fieldValue = fieldValue.toLowerCase();
          }

          parameters.add(field.toColumnType(fieldValue));

          opbrk = "";
          clbrk = "";
          conj = " AND ";
          not = false;

          break;
        case QueryOperation.isIn:
          field = entity.getFieldByName(i._args[0] as String);

          sql += clbrk + conj + opbrk;
          sql += field.columnName + (not ? " NOT IN (" : " IN (");
          for (int k = 1; k < i._args.length; k++) {
            if (k > 1) {
              sql += ", ";
            }
            sql += ("?");
            parameters.add(field.toColumnType(i._args[k]));
          }
          sql += ")";

          opbrk = "";
          clbrk = "";
          conj = " AND ";
          not = false;
          break;

        case QueryOperation.greaterThan:
        case QueryOperation.lessThan:
          field = entity.getFieldByName(i._args[0] as String);

          if (i._operation == QueryOperation.greaterThan) {
            op = (not ? " <= " : " > ");
          } else {
            op = (not ? " >= " : " < ");
          }

          sql += clbrk + conj + opbrk;
          sql += (field.columnName + op + " ? ");

          parameters.add(field.toColumnType(i._args[1]));

          opbrk = "";
          clbrk = "";
          conj = " AND ";
          not = false;
          break;
        case QueryOperation.and:
          // and gets added automatically
          break;
        case QueryOperation.noOperation:
          // ignore
          break;
        default:
          throw UnimplementedError();
      }
    }

    Orm.fillList(type, _internalValues, sql, parameters, localCache);
  }

  List<T> get _values {
    if (_internalValues.isEmpty) {
      if (reflectClass(T).isAbstract) {
        List<Object>? localCache;
        for (var item in Orm.getChildTypes(T)) {
          _fill(item, localCache);
        }
      } else {
        _fill(T, null);
      }
    }

    return _internalValues;
  }

  Query<T> _setOp(QueryOperation operation, List<Object> args) {
    _operation = operation;
    _args = args;

    return Query<T>(this);
  }

  // public methods
  Query<T> not() {
    return _setOp(QueryOperation.not, []);
  }

  Query<T> and() {
    return _setOp(QueryOperation.and, []);
  }

  Query<T> or() {
    return _setOp(QueryOperation.or, []);
  }

  Query<T> beginGroup() {
    return _setOp(QueryOperation.beginGroup, []);
  }

  Query<T> endGroup() {
    return _setOp(QueryOperation.endGroup, []);
  }

  Query<T> equals(String field, Object value, [bool ignoreCase = false]) {
    return _setOp(QueryOperation.equals, [field, value, ignoreCase]);
  }

  Query<T> like(String field, Object value) {
    // third param is true, as it always ignores case in sqlite
    return _setOp(QueryOperation.like, [field, value, true]);
  }

  Query<T> isIn(String field, List<Object> values) {
    var argList = List<Object>.from(values);
    argList.insert(0, field);
    return _setOp(QueryOperation.isIn, argList);
  }

  Query<T> greaterThan(String field, Object value) {
    return _setOp(QueryOperation.greaterThan, [field, value]);
  }

  Query<T> lessThan(String field, Object value) {
    return _setOp(QueryOperation.lessThan, [field, value]);
  }

  List<T> getList() {
    return List<T>.from(_values);
  }
}
