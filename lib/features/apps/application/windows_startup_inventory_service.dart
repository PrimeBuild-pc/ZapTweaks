import 'dart:convert';

import '../../../core/services/process_runner.dart';
import '../domain/startup_app.dart';

class WindowsStartupInventoryService {
  WindowsStartupInventoryService({required ProcessRunner processRunner})
    : _runner = processRunner;

  final ProcessRunner _runner;

  Future<List<StartupApp>> scan() async {
    final output = await _runner.runPowerShellForOutput(r'''
$items = @(Get-CimInstance Win32_StartupCommand -ErrorAction Stop | ForEach-Object {
  [pscustomobject]@{
    Name = [string]$_.Name
    Command = [string]$_.Command
    Location = [string]$_.Location
    User = [string]$_.User
  }
})
ConvertTo-Json -Compress -Depth 2 -InputObject $items
''');
    final decoded = jsonDecode(output.isEmpty ? '[]' : output);
    final rows = decoded is List ? decoded : <dynamic>[decoded];
    return rows
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          return StartupApp(
            name: map['Name']! as String,
            command: map['Command']! as String,
            location: map['Location']! as String,
            user: map['User']! as String,
          );
        })
        .toList(growable: false)
      ..sort((left, right) => left.name.compareTo(right.name));
  }
}
