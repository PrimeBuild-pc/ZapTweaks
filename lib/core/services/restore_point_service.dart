import '../models/restore_point_result.dart';
import 'process_runner.dart';

class RestorePointService {
  RestorePointService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    final command =
        r'Enable-ComputerRestore -Drive "C:\"; '
        r'Checkpoint-Computer -Description "__DESCRIPTION__" '
        r'-RestorePointType "MODIFY_SETTINGS"';

    final script = command.replaceAll('__DESCRIPTION__', description);

    final result = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      script,
    ]);

    if (!result.success) {
      return RestorePointResult(success: false, message: result.details);
    }

    return const RestorePointResult(success: true);
  }
}
