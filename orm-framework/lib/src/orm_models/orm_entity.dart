import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';
import 'package:collection/collection.dart';

class OrmEntity {
  OrmEntity(Type type){
    final DeclarationMirror classDeclaration = reflectClass(type);
    final ClassMirror entityAnnotationMirror = reflectClass(EntityMetadata);
    final InstanceMirror? annotationInstsanceMirror = classDeclaration.metadata.firstWhereOrNull((d) => d.type == entityAnnotationMirror);
    
    String? tableNameOfEntity;
    // if annotationInstsanceMirror is null, the annotation is no present
    if (annotationInstsanceMirror != null && (annotationInstsanceMirror.reflectee as EntityMetadata).tableName != null) {
      tableNameOfEntity = (annotationInstsanceMirror.reflectee as EntityMetadata).tableName;
    }

    if (tableNameOfEntity == null) {
      tableName = MirrorSystem.getName(classDeclaration.simpleName).toUpperCase();
    }
  }

  late Type member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
}