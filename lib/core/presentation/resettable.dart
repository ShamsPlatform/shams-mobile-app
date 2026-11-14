/// Contract for providers whose state must be cleared when a user signs out.
abstract interface class Resettable {
  void reset();
}
