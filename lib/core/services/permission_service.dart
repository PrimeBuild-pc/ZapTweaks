import 'process_runner.dart';

class PermissionService {
  PermissionService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<bool> isRunningElevated() async {
    final result = await _processRunner.run('net', <String>['session']);
    return result.success;
  }
}
