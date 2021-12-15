import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/foreignkey_annotation.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';
import 'dart:mirrors';
import 'package:collection/collection.dart';

/// The framework's OrmEntity implementation
class OrmEntity {
  /// Creates a new instance of [OrmEntity] for [type].
  OrmEntity(Type type) {
    member = reflectClass(type);

    EntityAnnotation? entityAnnotation = _getAnnotationOrNull<EntityAnnotation>(member);
    tableName = entityAnnotation?.tableName ?? MirrorSystem.getName(member.simpleName).toUpperCase();

    ClassMirror classMirror = member;
    var declarations = Map<Symbol, DeclarationMirror>.from(classMirror.declarations);

    while (classMirror.superclass != null) {
      declarations.addAll(classMirror.superclass!.declarations);
      classMirror = classMirror.superclass!;
    }

    List<OrmField> entityFields = [];
    declarations.forEach((Symbol key, DeclarationMirror value) {
      IgnoreAnnotation? ignoreAnnotation = _getAnnotationOrNull<IgnoreAnnotation>(value);

      if (ignoreAnnotation == null && value is VariableMirror && !value.isPrivate) {
        FieldAnnotation? fieldAnnotation = _getAnnotationOrNull(value);
        ForeignKeyAnnotation? foreignKeyAnnotation = _getAnnotationOrNull(value);
        PrimaryKeyAnnotation? primaryKeyAnnotation = _getAnnotationOrNull<PrimaryKeyAnnotation>(value);

        OrmField field = OrmField(
          this,
          value,
          value.type.reflectedType,
          fieldAnnotation?.columnName ??
              foreignKeyAnnotation?.columnName ??
              primaryKeyAnnotation?.columnName ??
              MirrorSystem.getName(key),
          fieldAnnotation?.columnType ??
              foreignKeyAnnotation?.columnType ??
              primaryKeyAnnotation?.columnType ??
              value.type.reflectedType,
          primaryKeyAnnotation != null,
          foreignKeyAnnotation != null,
          fieldAnnotation?.nullable ?? foreignKeyAnnotation?.nullable ?? primaryKeyAnnotation?.nullable ?? false,
        );

        if (foreignKeyAnnotation != null) {
          field.isExternal = reflectType(value.type.reflectedType).isAssignableTo(reflectType(Iterable));
          field.assignmentTable = foreignKeyAnnotation.assignmentTable;
          field.remoteColumnName = foreignKeyAnnotation.remoteColumnName;
          field.isManyToMany = !(field.assignmentTable?.trim().isEmpty ?? true);
        }

        if (primaryKeyAnnotation != null) {
          primaryKey = field;
        }

        entityFields.add(field);
      }
    });

    fields = entityFields;
    _internals = fields.where((element) => !element.isExternal).toList();
    _externals = fields.where((element) => element.isExternal).toList();
  }

  /// Gets or sets the member.
  late ClassMirror member;

  /// Gets or sets the table name.
  late String tableName;

  /// Gets or sets the fields.
  late List<OrmField> fields;

  /// Gets or sets the primary key field.
  late OrmField primaryKey;
  late List<OrmField> _internals;
  late List<OrmField> _externals;

  /// Gets the internal fields.
  List<OrmField> get internals => _internals;

  /// Gets the external fields.
  List<OrmField> get externals => _externals;

  /// Gets the SELECT-SQL of the entity.
  /// [columnPrefix] for adding a prefix to the columnname
  String getSql({String columnPrefix = ""}) {
    String selectStatement = "SELECT ";
    for (int i = 0; i < internals.length; i++) {
      // add ", " in front of the value after the first
      if (i > 0) {
        selectStatement += ", ";
      }
      selectStatement += columnPrefix.trim() + internals[i].columnName;
    }

    selectStatement += " FROM " + tableName;

    return selectStatement;
  }

  /// Gets the field for columnName.
  OrmField getFieldForColumn(String columnName) {
    for (OrmField internalField in internals) {
      if (columnName.toLowerCase() == internalField.columnName.toLowerCase()) {
        return internalField;
      }
    }
    throw Exception(columnName + "-field not found!");
  }

  /// Gets the field by its name.
  OrmField getFieldByName(String name) {
    for (OrmField internalField in fields) {
      if (MirrorSystem.getName(internalField.member.simpleName).toLowerCase() == name.toLowerCase()) {
        return internalField;
      }
    }
    throw Exception(name + "-field not found!");
  }

  T? _getAnnotationOrNull<T>(DeclarationMirror mirror) {
    final ClassMirror annotationClassMirror = reflectClass(T);
    InstanceMirror? instanceMirror = mirror.metadata.firstWhereOrNull((d) => d.type == annotationClassMirror);
    if (instanceMirror != null) {
      return instanceMirror.reflectee as T;
    }
  }
}
