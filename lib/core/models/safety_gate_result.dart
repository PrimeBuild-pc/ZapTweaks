enum SafetyGateStatus {
  proceed,
  cancelled,
  blockedMissingAdmin,
  restorePointFailed,
}

class SafetyGateResult {
  const SafetyGateResult({required this.status, this.message});

  final SafetyGateStatus status;
  final String? message;

  bool get allowsExecution => status == SafetyGateStatus.proceed;
}
