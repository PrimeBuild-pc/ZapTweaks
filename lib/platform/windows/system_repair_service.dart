import '../../core/services/process_runner.dart';

class RepairReport {
  const RepairReport({
    required this.action,
    required this.repairExitCode,
    required this.verificationExitCode,
    required this.verified,
  });

  final String action;
  final int repairExitCode;
  final int verificationExitCode;
  final bool verified;
}

class WindowsRepairService {
  const WindowsRepairService({required this.processRunner});

  final ProcessRunner processRunner;

  Future<RepairReport> repairComponentStore() => _run(
    action: 'DISM component store repair',
    executable: 'dism.exe',
    repairArguments: const <String>[
      '/Online',
      '/Cleanup-Image',
      '/RestoreHealth',
      '/NoRestart',
    ],
    verifyArguments: const <String>[
      '/Online',
      '/Cleanup-Image',
      '/ScanHealth',
      '/NoRestart',
    ],
  );

  Future<RepairReport> repairSystemFiles() => _run(
    action: 'SFC system file repair',
    executable: 'sfc.exe',
    repairArguments: const <String>['/scannow'],
    verifyArguments: const <String>['/verifyonly'],
  );

  Future<RepairReport> _run({
    required String action,
    required String executable,
    required List<String> repairArguments,
    required List<String> verifyArguments,
  }) async {
    final repair = await processRunner.run(
      executable,
      repairArguments,
      timeout: const Duration(hours: 2),
    );
    if (!repair.success) {
      return RepairReport(
        action: action,
        repairExitCode: repair.exitCode,
        verificationExitCode: -1,
        verified: false,
      );
    }
    final verification = await processRunner.run(
      executable,
      verifyArguments,
      timeout: const Duration(hours: 2),
    );
    return RepairReport(
      action: action,
      repairExitCode: repair.exitCode,
      verificationExitCode: verification.exitCode,
      verified: verification.success,
    );
  }
}
