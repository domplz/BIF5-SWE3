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
    fields = [];

    EntityMetadata? entityAnnotation = _getMetadataOrNull<EntityMetadata>(member);

    String? tableNameOfEntity;
    // if annotationInstsanceMirror is null, the annotation is no present
    if (entityAnnotation != null && entityAnnotation.tableName != null) {
      tableNameOfEntity = entityAnnotation.tableName;
    }

    if (tableNameOfEntity == null) {
      // if it could not be retrieved from the annotation, use the class name
      tableName = MirrorSystem.getName(member.simpleName).toUpperCase();
    } else {
      tableName = tableNameOfEntity;
    }

    final ClassMirror classClassMirror = reflectClass(type);
    classClassMirror.declarations.forEach((key, value) {
      IgnoreMetadata? ignoreAnnotation = _getMetadataOrNull<IgnoreMetadata>(value);

      if (!value.isPrivate && ignoreAnnotation == null) {
        OrmField field = OrmField(this);

        FieldMetadata? fieldMetadata = _getMetadataOrNull(value);

        if (fieldMetadata != null) {
          field.columnName = fieldMetadata.columnName ?? MirrorSystem.getName(key);
          field.columnType = fieldMetadata.columnType ?? value.runtimeType;
          field.isNullable = fieldMetadata.nullable ?? false;
        } else {
          field.columnName = MirrorSystem.getName(key);
          field.columnType = value.runtimeType;
          field.isNullable = false;
        }

        PrimaryKeyMetadata? primaryKeyMetadata = _getMetadataOrNull<PrimaryKeyMetadata>(value);
        final bool isPrimary = primaryKeyMetadata != null;

        ForeignKeyMetadata? foreignKeyMetadata = _getMetadataOrNull(value);
        final bool isForeignKey = foreignKeyMetadata != null;

        field.isPrimaryKey = isPrimary;
        field.isForeignKey = isForeignKey;
        field.member = value;

        fields.add(field);
      }
    });
  }

  late DeclarationMirror member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;

  T? _getMetadataOrNull<T>(DeclarationMirror mirror) {
    final ClassMirror annotationClassMirror = reflectClass(T);
    InstanceMirror? instanceMirror = mirror.metadata.firstWhereOrNull((d) => d.type == annotationClassMirror);
    if (instanceMirror != null) {
      return instanceMirror.reflectee as T;
    }
  }
}
