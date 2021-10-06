import 'dart:mirrors';

import 'package:orm_framework/src/orm_models/orm_entity.dart';
import 'package:sqlite3/sqlite3.dart';

class Orm {
  static final Map<Type, OrmEntity> _entities = <Type, OrmEntity>{};

  static late Database database;

  static OrmEntity getEntity(Object object){

    // get type from object
    Type type;
    if (object is Type){
      type = object;
    }
    else {
      type = object.runtimeType;
    }

    // add to dictonary if not allready in it
    if (!_entities.containsKey(type)){
      _entities[type] = OrmEntity(type);
    }

    var entity = _entities[type];
    if(entity != null){
      return entity;
    }
    
    throw Exception("Entity in dictionary is null! (Should not happen, as it was just added)");
  }

  static save(Object object) async {
    
    OrmEntity entity = Orm.getEntity(object);

    final stmt = database.prepare('INSERT INTO artists (name) VALUES (?)');
    stmt
      ..execute(['The Beatles'])
      ..execute(['Led Zeppelin'])
      ..execute(['The Who'])
      ..execute(['Nirvana']);
  }

  static T get<T>(Object primaryKey){
    return _createObject(T, primaryKey) as T;
  }

  static List<T> getAll<T>(){
    return _createAllObjects(T) as List<T>;
  }

  static List<Object> _createAllObjects(Type t){
    String commandText = Orm.getEntity(t).getSql();
    ResultSet resultSet = database.select(commandText);

      if(resultSet.isEmpty){
        throw Exception("The query did not return any rows. It returned " + resultSet.length.toString());
      }
      List<Object> objects = <Object>[];
      for (var element in resultSet) {
          objects.add(_createObjectFromRow(t, element));
      }
      return objects;
  }

  static Object _createObject(Type t, Object primaryKey){
    String commandText = Orm.getEntity(t).getSql() + " WHERE " + Orm.getEntity(t).primaryKey.columnName + " = :pk ";
    ResultSet resultSet = database.select(commandText, [primaryKey]);

      if(resultSet.length != 1){
        throw Exception("The query did not return 1 row. It returned " + resultSet.length.toString());
      }

      return _createObjectFromRow(t, resultSet.first);   
  }

  static Object _createObjectFromRow(Type type, Row row){
    
    late InstanceMirror instance;
    var typeMirror = reflectType(type);
    if (typeMirror is ClassMirror) {
       instance = typeMirror.newInstance(Symbol(""), const []).reflectee;
    } else {
      throw ArgumentError("Cannot create the instance of the type '$type'.");
    }
    
    Orm.getEntity(type).fields.forEach((element) {
      
      instance.setField(Symbol(element.columnName), element.toFieldType([element.columnName]));
    });

    return instance;
  }
}