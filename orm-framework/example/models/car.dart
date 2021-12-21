import 'package:orm_framework/src/annotations/entity_annotation.dart';
import 'package:orm_framework/src/annotations/field_annotation.dart';
import 'package:orm_framework/src/annotations/ignore_annotation.dart';
import 'package:orm_framework/src/annotations/primarykey_annotation.dart';

@EntityAnnotation(tableName: "BeautifulCarsTable")
class Car {
  @PrimaryKeyAnnotation(columnName: "car_id")
  late String id;
  late String name;
  late DateTime productionDate;
  late int horsePower;
  @FieldAnnotation(nullable: true)
  late double? fuelConsumption;

  @IgnoreAnnotation()
  String? notes;
}
