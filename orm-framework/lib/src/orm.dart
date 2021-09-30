import 'package:orm_framework/src/orm_models/orm_entity.dart';

class Orm {
  static final Map<Type, OrmEntity> _entities = <Type, OrmEntity>{};

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
}