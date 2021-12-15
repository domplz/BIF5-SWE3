/// Abstract implementation of [Locking]
abstract class Locking {
  /// Locks the [object]
  void lock(Object object);

  /// Releases the [object]
  void release(Object object);
}
