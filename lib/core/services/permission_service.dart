import 'process_runner.dart';

class PermissionService {
  PermissionService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<bool> isRunningElevated() async {
    // `net session` reports failure when the Server service is disabled, even
    // for an elevated process. Query the current access token instead.
    final result = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      r'''$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator).ToString().ToLower()''',
    ]);
    return result.success && result.stdout.trim().toLowerCase() == 'true';
  }
}
