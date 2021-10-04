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
        FieldAnnotation? fieldAnnotation = _getAnnotationOrNull(value);
        ForeignKeyAnnotation? foreignKeyAnnotation = _getAnnotationOrNull(value);
        PrimaryKeyAnnotation? primaryKeyAnnotation = _getAnnotationOrNull<PrimaryKeyAnnotation>(value);

        OrmField field = OrmField(
          this,
          value,
          fieldAnnotation?.columnType ?? foreignKeyAnnotation?.columnType ?? primaryKeyAnnotation?.columnType ?? value.runtimeType,
          fieldAnnotation?.columnName ?? foreignKeyAnnotation?.columnName ?? primaryKeyAnnotation?.columnName ?? MirrorSystem.getName(key),
          fieldAnnotation?.columnType ?? foreignKeyAnnotation?.columnType ?? primaryKeyAnnotation?.columnType ?? value.runtimeType,
          primaryKeyAnnotation != null,
          foreignKeyAnnotation != null,
          fieldAnnotation?.nullable ?? foreignKeyAnnotation?.nullable ?? primaryKeyAnnotation?.nullable ?? false,
        );

        if (primaryKeyAnnotation != null) {
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
