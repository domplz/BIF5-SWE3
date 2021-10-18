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

    ClassMirror classMirror = member;
    var declarations = Map<Symbol, DeclarationMirror>.from(classMirror.declarations);

    while (classMirror.superclass != null) {
      declarations.addAll(classMirror.superclass!.declarations);
      classMirror = classMirror.superclass!;
    }

    declarations.forEach((key, value) {
      IgnoreAnnotation? ignoreAnnotation = _getAnnotationOrNull<IgnoreAnnotation>(value);

      // for some reasone runTimeType == VariableMirror is not working
      if (!value.isPrivate && value.runtimeType.toString() == "_VariableMirror" && ignoreAnnotation == null) {
        FieldAnnotation? fieldAnnotation = _getAnnotationOrNull(value);
        ForeignKeyAnnotation? foreignKeyAnnotation = _getAnnotationOrNull(value);
        PrimaryKeyAnnotation? primaryKeyAnnotation = _getAnnotationOrNull<PrimaryKeyAnnotation>(value);

        OrmField field = OrmField(
          this,
          value as VariableMirror,
          fieldAnnotation?.columnType ?? foreignKeyAnnotation?.columnType ?? primaryKeyAnnotation?.columnType ?? value.type.reflectedType,
          fieldAnnotation?.columnName ?? foreignKeyAnnotation?.columnName ?? primaryKeyAnnotation?.columnName ?? MirrorSystem.getName(key),
          fieldAnnotation?.columnType ?? foreignKeyAnnotation?.columnType ?? primaryKeyAnnotation?.columnType ?? value.type.reflectedType,
          primaryKeyAnnotation != null,
          foreignKeyAnnotation != null,
          fieldAnnotation?.nullable ?? foreignKeyAnnotation?.nullable ?? primaryKeyAnnotation?.nullable ?? false,
        );

        if (primaryKeyAnnotation != null) {
          primaryKey = field;
        }

        if (foreignKeyAnnotation != null) {
          field.isExternal = MirrorSystem.getName(reflectType(value.type.reflectedType).simpleName) == "List";
          field.assignmentTable = foreignKeyAnnotation.assignmentTable;
          field.remoteColumnName = foreignKeyAnnotation.remoteColumnName;
          field.isManyToMany = !(field.assignmentTable?.trim().isEmpty ?? true);
        }

        fields.add(field);
      }
    });

    _internals = fields.where((element) => !element.isExternal).toList();
    _externals = fields.where((element) => element.isExternal).toList();
  }

  late ClassMirror member;
  late String tableName;
  late List<OrmField> fields;
  late OrmField primaryKey;
  late List<OrmField> _internals;
  late List<OrmField> _externals;

  List<OrmField> get internals => _internals;
  List<OrmField> get externals => _externals;

  String getSql({String prefix = ""}) {
    String selectStatement = "Select ";
    for (int i = 0; i < internals.length; i++) {
      // add ", " in front of the value after the first
      if (i > 0) {
        selectStatement += ", ";
      }
      selectStatement += prefix.trim() + internals[i].columnName;
    }

    selectStatement += " FROM " + tableName;

    return selectStatement;
  }

  OrmField getFieldForColumn(String columnName) {
    for (OrmField internalField in internals) {
      if (columnName.toUpperCase() == internalField.columnName.toUpperCase()) {
        return internalField;
      }
    }
    throw Exception(columnName + "-field not found!");
  }

  T? _getAnnotationOrNull<T>(DeclarationMirror mirror) {
    final ClassMirror annotationClassMirror = reflectClass(T);
    InstanceMirror? instanceMirror = mirror.metadata.firstWhereOrNull((d) => d.type == annotationClassMirror);
    if (instanceMirror != null) {
      return instanceMirror.reflectee as T;
    }
  }
}
