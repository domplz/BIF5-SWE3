import 'package:orm_framework/src/locking/locking.dart';
import 'package:orm_framework/src/locking/object_locked_exception.dart';
import 'package:orm_framework/src/orm.dart';
import 'package:uuid/uuid.dart';

/// DbLocking implementation
/// Stores the locking information to a database
/// If the Locking - Table does not exist, it will be created
class DbLocking implements Locking {
  String _sessionKey = "OhComeOnDart";
  int _timeOut = 180;
  String _lockTableName = "LOCK";

  /// Creates a new instance of [DbLocking].
  /// [sessionKeyParam] the sessionKey to use.
  /// [lockTableNameParam] the table name to use. Table will be created, if not exists.
  /// [timeOutParam] the timeOut to use.
  DbLocking({String? sessionKeyParam, String? lockTableNameParam, int? timeOutParam}) {
    if (sessionKeyParam != null && _sessionKey.isNotEmpty) {
      _sessionKey = _sessionKey;
    } else {
      _sessionKey = Uuid().v4().toString();
    }

    if (lockTableNameParam != null && lockTableNameParam.isNotEmpty) {
      _lockTableName = lockTableNameParam;
    }

    if (timeOutParam != null) {
      _timeOut = timeOutParam;
    }

    String createCommand =
        "CREATE TABLE IF NOT EXISTS $_lockTableName (JCLASS VARCHAR(48) NOT NULL, JOBJECT VARCHAR(48) NOT NULL, JTIME TIMESTAMP NOT NULL, JOWNER VARCHAR(48))";
    Orm.database.execute(createCommand);

    String indexCommand = "CREATE UNIQUE INDEX IF NOT EXISTS UX_LOCKS ON $_lockTableName(JCLASS, JOBJECT)";
    Orm.database.execute(indexCommand);
  }

  _getClassKey(Object object) {
    return Orm.getEntity(object).tableName;
  }

  _getObjectKey(Object object) {
    var entity = Orm.getEntity(object);
    return entity.primaryKey.toColumnType(entity.primaryKey.getValue(object)).toString();
  }

  String? _getLock(Object object) {
    String classKey = _getClassKey(object);
    String objectKey = _getObjectKey(object);

    String command = "SELECT JOWNER FROM $_lockTableName WHERE JCLASS = ? AND JOBJECT = ?";
    List<String> params = [classKey, objectKey];

    var result = Orm.database.select(command, params);
    if (result.isNotEmpty) {
      return result.first["JOWNER"];
    }

    return null;
  }

  _createLock(Object object) {
    String classKey = _getClassKey(object);
    String objectKey = _getObjectKey(object);

    String command = "INSERT INTO $_lockTableName (JCLASS, JOBJECT, JTIME, JOWNER) VALUES (?, ?, CURRENT_TIMESTAMP, ?)";
    List<String> params = [classKey, objectKey, _sessionKey];

    try {
      Orm.database.execute(command, params);

      // we want that here
      // ignore: empty_catches
    } on Exception {}
  }

  /// Locks the [object].
  /// If object is locked by another session, [ObjectLockedException] is thrown.
  @override
  void lock(Object object) {
    String? owner = _getLock(object);

    if (owner == _sessionKey) {
      return;
    }
    if (owner == null) {
      _createLock(object);
      owner = _getLock(object);
    }

    if (owner != _sessionKey) {
      throw ObjectLockedException();
    }
  }

  /// Releases the [object].
  @override
  void release(Object object) {
    String classKey = _getClassKey(object);
    String objectKey = _getObjectKey(object);

    String command = "DELETE FROM $_lockTableName WHERE JCLASS = ? AND JOBJECT = ? AND JOWNER = ?";
    List<String> params = [classKey, objectKey, _sessionKey];

    Orm.database.execute(command, params);
  }

  /// Releases all locks of objects, where the lock is older than [_timeOut]
  void purge() {
    String command =
        "DELETE FROM $_lockTableName WHERE ((JulianDay(CURRENT_TIMESTAMP) - JulianDay(JTIME)) * 86400) > ?";
    List<String> params = [_timeOut.toString()];

    Orm.database.execute(command, params);
  }
}
