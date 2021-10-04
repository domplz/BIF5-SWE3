import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';
import 'package:collection/collection.dart';

class OrmEntity {
  OrmEntity(Type type) {
    member = reflectClass(type);
    fields = [];

    EntityAnnotation? entityAnnotation = _getAnnotationOrNull<EntityAnnotation>(member);
    tableName = entityAnnotation?.tableName ?? MirrorSystem.getName(member.simpleName).toUpperCase();

    final ClassMirror classClassMirror = reflectClass(type);
    classClassMirror.declarations.forEach((key, value) {
      IgnoreAnnotation? ignoreAnnotation = _getAnnotationOrNull<IgnoreAnnotation>(value);

      // for some reasone runTimeType == VariableMirror is not working
      if (!value.isPrivate && value.runtimeType.toString() == "_VariableMirror" && ignoreAnnotation == null) {
        FieldAnnotation? fieldMetadata = _getAnnotationOrNull(value);
        ForeignKeyAnnotation? foreignKeyMetadata = _getAnnotationOrNull(value);
        PrimaryKeyAnnotation? primaryKeyMetadata = _getAnnotationOrNull<PrimaryKeyAnnotation>(value);

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

        if (primaryKeyMetadata != null) {
          primaryKey = field;
        }

        fields.add(field);
      }
    });
  }

  late DeclarationMirror member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;

  T? _getAnnotationOrNull<T>(DeclarationMirror mirror) {
    final ClassMirror annotationClassMirror = reflectClass(T);
    InstanceMirror? instanceMirror = mirror.metadata.firstWhereOrNull((d) => d.type == annotationClassMirror);
    if (instanceMirror != null) {
      return instanceMirror.reflectee as T;
    }
  }
}
