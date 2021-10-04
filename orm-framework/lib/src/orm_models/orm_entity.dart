import 'package:orm_framework/src/orm_metadata/entity_metadata.dart';
import 'package:orm_framework/src/orm_metadata/field_metadata.dart';
import 'package:orm_framework/src/orm_metadata/foreign_key_metadata.dart';
import 'package:orm_framework/src/orm_metadata/ignore_metadata.dart';
import 'package:orm_framework/src/orm_metadata/primary_key_metadata.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';
import 'package:collection/collection.dart';

class OrmEntity {
  OrmEntity(Type type) {
    member = reflectClass(type);

    final ClassMirror metadataClassMirror = reflectClass(EntityMetadata);
    final InstanceMirror? annotationInstsanceMirror = member.metadata.firstWhereOrNull((d) => d.type == metadataClassMirror);

    String? tableNameOfEntity;
    // if annotationInstsanceMirror is null, the annotation is no present
    if (annotationInstsanceMirror != null && (annotationInstsanceMirror.reflectee as EntityMetadata).tableName != null) {
      tableNameOfEntity = (annotationInstsanceMirror.reflectee as EntityMetadata).tableName;
    }

    if (tableNameOfEntity == null) {
      tableName = MirrorSystem.getName(member.simpleName).toUpperCase();
    } else {
      tableName = tableNameOfEntity;
    }

    List<OrmField> fieldList = <OrmField>[];

    final ClassMirror classClassMirror = reflectClass(type);
    classClassMirror.declarations.forEach((key, value) {
      final ClassMirror ignoreMetadataClassMirror = reflectClass(IgnoreMetadata);
      final bool isIgnored = member.metadata.firstWhereOrNull((d) => d.type == ignoreMetadataClassMirror) != null;

      if (!value.isPrivate && !isIgnored) {
        OrmField field = OrmField(this);

        final ClassMirror fieldMetadataClassMirror = reflectClass(FieldMetadata);
        final InstanceMirror? fieldInstanceMirror = member.metadata.firstWhereOrNull((d) => d.type == fieldMetadataClassMirror);

        if (fieldInstanceMirror != null) {
          field.columnName = (fieldInstanceMirror.reflectee as FieldMetadata).columnName ?? MirrorSystem.getName(key);
          field.columnType = (fieldInstanceMirror.reflectee as FieldMetadata).columnType ?? value.runtimeType;
          field.isNullable = (fieldInstanceMirror.reflectee as FieldMetadata).nullable ?? false;
        } else {
          field.columnName = MirrorSystem.getName(key);
          field.columnType = value.runtimeType;
          field.isNullable = false;
        }

        final ClassMirror primaryKeyMetadataClassMirror = reflectClass(PrimaryKeyMetadata);
        final bool isPrimary = member.metadata.firstWhereOrNull((d) => d.type == primaryKeyMetadataClassMirror) != null;

        final ClassMirror foreignKeyMetadataClassMirror = reflectClass(ForeignKeyMetadata);
        final bool isForeignKey = member.metadata.firstWhereOrNull((d) => d.type == foreignKeyMetadataClassMirror) != null;

        field.isPrimaryKey = isPrimary;
        field.isForeignKey = isForeignKey;
        field.member = value;

        fieldList.add(field);
      }
    });

    fields = fieldList;
  }

  late DeclarationMirror member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
}
