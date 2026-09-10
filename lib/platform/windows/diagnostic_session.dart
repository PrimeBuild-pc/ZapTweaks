typedef AsyncAction = Future<void> Function();

class DiagnosticSession {
  const DiagnosticSession({required this.start, required this.stop});

  final AsyncAction start;
  final AsyncAction stop;

  Future<T> run<T>(Future<T> Function() collect) async {
    await start();
    try {
      return await collect();
    } finally {
      await stop();
    }
  }
}
