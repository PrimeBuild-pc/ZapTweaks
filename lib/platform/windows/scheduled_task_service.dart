import 'dart:convert';

import '../../core/services/process_runner.dart';

class ScheduledTaskState {
  const ScheduledTaskState({
    required this.path,
    required this.name,
    required this.enabled,
  });

  final String path;
  final String name;
  final bool enabled;
}

abstract interface class ScheduledTaskStore {
  Future<ScheduledTaskState> inspect(String path, String name);
  Future<void> setEnabled(String path, String name, bool enabled);
}

class WindowsScheduledTaskService implements ScheduledTaskStore {
  WindowsScheduledTaskService({ProcessRunner? processRunner})
    : _runner = processRunner ?? ProcessRunner.shared;

  final ProcessRunner _runner;

  static String _encoded(String value) {
    if (value.isEmpty || value.length > 256 || value.runes.any((r) => r < 32)) {
      throw ArgumentError('Invalid scheduled task identity.');
    }
    return base64Encode(utf8.encode(value));
  }

  @override
  Future<ScheduledTaskState> inspect(String path, String name) async {
    final encodedPath = _encoded(path);
    final encodedName = _encoded(name);
    final output = await _runner.runPowerShellForOutput('''
\$p=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedPath'))
\$n=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedName'))
\$t=Get-ScheduledTask -TaskPath \$p -TaskName \$n -ErrorAction Stop
[ordered]@{path=[string]\$t.TaskPath;name=[string]\$t.TaskName;enabled=([string]\$t.State -ne 'Disabled')} | ConvertTo-Json -Compress
''');
    final json = Map<String, dynamic>.from(jsonDecode(output) as Map);
    return ScheduledTaskState(
      path: json['path']! as String,
      name: json['name']! as String,
      enabled: json['enabled']! as bool,
    );
  }

  @override
  Future<void> setEnabled(String path, String name, bool enabled) async {
    final encodedPath = _encoded(path);
    final encodedName = _encoded(name);
    final verb = enabled ? 'Enable-ScheduledTask' : 'Disable-ScheduledTask';
    await _runner.runPowerShellForOutput('''
\$p=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedPath'))
\$n=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedName'))
$verb -TaskPath \$p -TaskName \$n -ErrorAction Stop | Out-Null
'OK'
''');
  }
}
