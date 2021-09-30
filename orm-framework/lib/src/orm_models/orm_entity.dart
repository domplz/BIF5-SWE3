import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_metadata/ignore_metadata.dart';
import 'package:orm_framework/src/orm_metadata/primary_key_metadata.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';
import 'package:collection/collection.dart';

class OrmEntity {
  OrmEntity(Type type){
    member = type;

    final DeclarationMirror classDeclarationMirror = reflectClass(type);
    final ClassMirror metadataClassMirror = reflectClass(EntityMetadata);
    final InstanceMirror? annotationInstsanceMirror = classDeclarationMirror.metadata.firstWhereOrNull((d) => d.type == metadataClassMirror);
    
    String? tableNameOfEntity;
    // if annotationInstsanceMirror is null, the annotation is no present
    if (annotationInstsanceMirror != null && (annotationInstsanceMirror.reflectee as EntityMetadata).tableName != null) {
      tableNameOfEntity = (annotationInstsanceMirror.reflectee as EntityMetadata).tableName;
    }

    if (tableNameOfEntity == null) {
      tableName = MirrorSystem.getName(classDeclarationMirror.simpleName).toUpperCase();
    }

    List<OrmField> fields = <OrmField>[];

    final ClassMirror classClassMirror = reflectClass(type);
    classClassMirror.declarations.forEach((_, value) {
      
      final ClassMirror ignoreMetadataClassMirror = reflectClass(IgnoreMetadata);
      final bool isIgnored = classDeclarationMirror.metadata.firstWhereOrNull((d) => d.type == ignoreMetadataClassMirror) != null;

      if(!value.isPrivate && !isIgnored){
        OrmField field = (this);
        final ClassMirror primaryKeyMetadataClassMirror = reflectClass(PrimaryKeyMetadata);
        final bool isPrimary = classDeclarationMirror.metadata.firstWhereOrNull((d) => d.type == primaryKeyMetadataClassMirror) != null;
      }
    });
  }

  late Type member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
}