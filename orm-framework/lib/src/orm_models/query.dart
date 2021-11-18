import 'dart:collection';
import 'dart:mirrors';
import 'package:tuple/tuple.dart';

import 'package:orm_framework/orm_framework.dart';
import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'package:orm_framework/src/orm_models/query_operation.dart';

class Query<T> with IterableMixin<T> {
  final Query<T>? _previous;
  final QueryOperation _operation = QueryOperation.nop;
  final List<Object> _args = [];
  List<T> _internalValues = [];

  @override
  Iterator<T> get iterator => _internalValues.iterator;

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
    List<Tuple2<String, Object>> parameters = [];
    String conj = " WHERE ";
    bool not = false;
    String opbrk = "";
    String clbrk = "";
    int n = 0;
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
        case QueryOperation.grp:
          opbrk += "(";
          break;
        case QueryOperation.endgrp:
          opbrk += ")";
          break;
        case QueryOperation.equals:
        case QueryOperation.like:
          String arg = i._args.first.toString();
          field = entity.getFieldByName(arg.toString());

          if (i._operation == QueryOperation.like) {
            op = (not ? " NOT LIKE " : " LIKE ");
          } else {
            op = (not ? " != " : " = ");
          }

          sql += clbrk + conj + opbrk;

          if (_args[2] as bool) {
            sql += "LOWER(${field.columnName})";
          } else {
            sql += field.columnName;
          }

          if ((_args[2]) as bool) {
            sql += "LOWER(${n.toString()})";
          } else {
            sql += n.toString();
          }

          if ((i._args[2] as bool)) {
            i._args[1] = (i._args[1] as String).toLowerCase();
          }

          parameters.add(Tuple2<String, Object>(":p" + (n++).toString(), field.toColumnType(i._args[1])));

          opbrk = clbrk = "";
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
            sql += (":p" + n.toString());
            parameters.add(Tuple2<String, Object>(":p" + (n++).toString(), field.toColumnType(i._args[k])));
          }
          sql += ")";

          opbrk = "";
          clbrk = "";
          conj = " AND ";
          not = false;
          break;

        case QueryOperation.gt:
        case QueryOperation.lt:
          field = entity.getFieldByName(i._args[0] as String);

          if (i._operation == QueryOperation.gt) {
            op = (not ? " <= " : " > ");
          } else {
            op = (not ? " >= " : " < ");
          }

          sql += clbrk + conj + opbrk;
          sql += (field.columnName + op + ":p" + n.toString());

          parameters.add(Tuple2<String, Object>(":p" + (n++).toString(), field.toColumnType(i._args[1])));

          opbrk = "";
          clbrk = "";
          conj = " AND ";
          not = false;
          break;
        default:
          throw UnimplementedError();
      }
    }

    // todo
    // Orm.fillList()
  }

  List<T> get _values {
    if (_internalValues.isEmpty) {
      if (reflectClass(T).isAbstract) {
        List<Object>? localCache;
        for (var item in Orm.getChildTypes(T)) {
          _fill(item, localCache);
        }
      }
    } else {
      _fill(T.runtimeType, null);
    }

    return _internalValues;
  }
}
