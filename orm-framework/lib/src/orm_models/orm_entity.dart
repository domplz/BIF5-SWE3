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
    tableName = entityAnnotation?.tableName ?? MirrorSystem.getName(member.simpleName).toUpperCase();

    final ClassMirror classClassMirror = reflectClass(type);
    classClassMirror.declarations.forEach((key, value) {
      IgnoreMetadata? ignoreAnnotation = _getMetadataOrNull<IgnoreMetadata>(value);

      // for some reasone runTimeType == VariableMirror is not working
      if (!value.isPrivate && value.runtimeType.toString() == "_VariableMirror" && ignoreAnnotation == null) {
        FieldMetadata? fieldMetadata = _getMetadataOrNull(value);
        ForeignKeyMetadata? foreignKeyMetadata = _getMetadataOrNull(value);

        PrimaryKeyMetadata? primaryKeyMetadata = _getMetadataOrNull<PrimaryKeyMetadata>(value);

        OrmField field = OrmField(
          this,
          value,
          fieldMetadata?.columnType ?? foreignKeyMetadata?.columnType ?? primaryKeyMetadata?.columnType ?? value.runtimeType,
          fieldMetadata?.columnName ?? foreignKeyMetadata?.columnName ?? primaryKeyMetadata?.columnName ?? MirrorSystem.getName(key),
          fieldMetadata?.columnType ?? foreignKeyMetadata?.columnType ?? primaryKeyMetadata?.columnType ?? value.runtimeType,
          primaryKeyMetadata != null,
          foreignKeyMetadata != null,
          fieldMetadata?.nullable ?? foreignKeyMetadata?.nullable ?? primaryKeyMetadata?.nullable ?? false,
        );

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
