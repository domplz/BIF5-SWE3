class ObjectLockedException implements Exception {
  String? cause;
  ObjectLockedException([this.cause = "Object is locked!"]);
}
