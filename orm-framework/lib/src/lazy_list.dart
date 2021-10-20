import 'dart:math';

import 'package:orm_framework/src/lazy.dart';
import 'package:orm_framework/src/orm_models/orm_field.dart';

import '../orm_framework.dart';

class LazyList<T> implements List<T>, Lazy{
  @override
  T get first => throw UnimplementedError();

  @override
  T get last => throw UnimplementedError();

  @override
  int get length => throw UnimplementedError();

  final List<T> _internalItems = <T>[];

  String _sql;

  List<String> _sqlParams;

  LazyList(this._sql, this._sqlParams);
  LazyList.fromObjectAndFieldName(Object object, String fieldName) {
    OrmField field = Orm.getEntity(object).getFieldByName(fieldName);
    _sql = field._fkSql;
    _sqlParams = <String>[
      field.entity.primaryKey.toColumnType(field.entity.primaryKey.getValue(object)),
    ];
  }

  @override
  List<T> operator +(List<T> other) {
    // TODO: implement +
    throw UnimplementedError();
  }

  @override
  T operator [](int index) {
    // TODO: implement []
    throw UnimplementedError();
  }

  @override
  void operator []=(int index, T value) {
    // TODO: implement []=
  }

  @override
  void add(T value) {
    // TODO: implement add
  }

  @override
  void addAll(Iterable<T> iterable) {
    // TODO: implement addAll
  }

  @override
  bool any(bool Function(T element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Map<int, T> asMap() {
    // TODO: implement asMap
    throw UnimplementedError();
  }

  @override
  List<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  bool contains(Object? element) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  T elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  bool every(bool Function(T element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(T element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    // TODO: implement fillRange
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function() orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, T element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(T element) action) {
    // TODO: implement forEach
  }

  @override
  Iterable<T> getRange(int start, int end) {
    // TODO: implement getRange
    throw UnimplementedError();
  }

  @override
  int indexOf(T element, [int start = 0]) {
    // TODO: implement indexOf
    throw UnimplementedError();
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    // TODO: implement indexWhere
    throw UnimplementedError();
  }

  @override
  void insert(int index, T element) {
    // TODO: implement insert
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    // TODO: implement insertAll
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement iterator
  Iterator<T> get iterator => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    // TODO: implement lastIndexOf
    throw UnimplementedError();
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    // TODO: implement lastIndexWhere
    throw UnimplementedError();
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function() orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> map<T>(T Function(T e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  bool remove(Object? value) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  T removeAt(int index) {
    // TODO: implement removeAt
    throw UnimplementedError();
  }

  @override
  T removeLast() {
    // TODO: implement removeLast
    throw UnimplementedError();
  }

  @override
  void removeRange(int start, int end) {
    // TODO: implement removeRange
  }

  @override
  void removeWhere(bool Function(T element) test) {
    // TODO: implement removeWhere
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    // TODO: implement replaceRange
  }

  @override
  void retainWhere(bool Function(T element) test) {
    // TODO: implement retainWhere
  }

  @override
  // TODO: implement reversed
  Iterable<T> get reversed => throw UnimplementedError();

  @override
  void setAll(int index, Iterable<T> iterable) {
    // TODO: implement setAll
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    // TODO: implement setRange
  }

  @override
  void shuffle([Random? random]) {
    // TODO: implement shuffle
  }

  @override
  // TODO: implement single
  T get single => throw UnimplementedError();

  @override
  T singleWhere(bool Function(T element) test, {T Function() orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  void sort([int Function(T a, T b) compare]) {
    // TODO: implement sort
  }

  @override
  List<T> sublist(int start, [int? end]) {
    // TODO: implement sublist
    throw UnimplementedError();
  }

  @override
  Iterable<T> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<T> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Set<T> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }
}