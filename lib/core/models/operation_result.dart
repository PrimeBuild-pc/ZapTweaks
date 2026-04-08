class OperationResult {
  const OperationResult({
    required this.success,
    this.message,
    this.shouldExitApp = false,
  });

  final bool success;
  final String? message;
  final bool shouldExitApp;

  static const OperationResult ok = OperationResult(success: true);
}
