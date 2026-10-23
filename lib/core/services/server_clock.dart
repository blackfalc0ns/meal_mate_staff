/// Keeps server time stable while avoiding wall-clock jumps during a deadline.
class ServerClock {
  DateTime? _serverAtSync;
  Stopwatch? _elapsed;

  bool get isSynchronized => _serverAtSync != null && _elapsed != null;

  void synchronize(DateTime serverUtc) {
    _serverAtSync = serverUtc.toUtc();
    _elapsed = Stopwatch()..start();
  }

  DateTime? get nowUtc {
    final server = _serverAtSync;
    final elapsed = _elapsed;
    if (server == null || elapsed == null) return null;
    return server.add(elapsed.elapsed);
  }

  DateTime get nowUtcOrLocal => nowUtc ?? DateTime.now().toUtc();
}
