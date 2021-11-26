import 'package:orm_framework/src/orm.dart';
import 'package:orm_framework/src/orm_models/locking.dart';
import 'package:orm_framework/src/orm_models/object_locked_exception.dart';
import 'package:uuid/uuid.dart';

class DbLocking implements Locking {
  String sessionKey = "OhComeOnDart";
  int timeOut = 180;
  String lockTableName = "LOCK";

  DbLocking({String? sessionKeyParam, String? lockTableNameParam}) {
    if (sessionKeyParam != null && sessionKey.isNotEmpty) {
      sessionKey = sessionKey;
    } else {
      sessionKey = Uuid().v4().toString();
    }

    if (lockTableNameParam != null && lockTableNameParam.isNotEmpty) {
      lockTableName = lockTableNameParam;
    }

    String createCommand =
        "CREATE TABLE IF NOT EXISTS $lockTableName (JCLASS VARCHAR(48) NOT NULL, JOBJECT VARCHAR(48) NOT NULL, JTIME TIMESTAMP NOT NULL, JOWNER VARCHAR(48))";
    Orm.database.execute(createCommand);

    String indexCommand = "CREATE UNIQUE INDEX IF NOT EXISTS UX_LOCKS ON $lockTableName(JCLASS, JOBJECT)";
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

    String command = "SELECT JOWNER FROM $lockTableName WHERE JCLASS = ? AND JOBJECT = ?";
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

    String command = "INSERT INTO $lockTableName (JCLASS, JOBJECT, JTIME, JOWNER) VALUES (?, ?, CURRENT_TIMESTAMP, ?)";
    List<String> params = [classKey, objectKey, sessionKey];

    try {
      Orm.database.execute(command, params);

      // we want that here
      // ignore: empty_catches
    } on Exception {}
  }

  @override
  void lock(Object object) {
    String? owner = _getLock(object);

    if (owner == sessionKey) {
      return;
    }
    if (owner == null) {
      _createLock(object);
      owner = _getLock(object);
    }

    if (owner != sessionKey) {
      throw ObjectLockedException();
    }
  }

  @override
  void release(Object object) {
    String classKey = _getClassKey(object);
    String objectKey = _getObjectKey(object);

    String command = "DELETE FROM $lockTableName WHERE JCLASS = ? AND JOBJECT = ? AND JOWNER = ?";
    List<String> params = [classKey, objectKey, sessionKey];

    Orm.database.execute(command, params);
  }

  void purge() {
    String command = "DELETE FROM $lockTableName WHERE ((JulianDay(CURRENT_TIMESTAMP) - JulianDay(JTIME)) * 86400) > t";
    List<String> params = [timeOut.toString()];

    Orm.database.execute(command, params);
  }
}
