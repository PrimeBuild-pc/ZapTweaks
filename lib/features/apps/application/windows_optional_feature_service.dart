import 'dart:convert';

import '../../../core/services/process_runner.dart';
import '../domain/windows_optional_feature.dart';

class WindowsOptionalFeatureService {
  WindowsOptionalFeatureService({required ProcessRunner processRunner})
    : _runner = processRunner;

  final ProcessRunner _runner;
  static final RegExp validName = RegExp(r'^[A-Za-z0-9_.-]{1,200}$');

  Future<List<WindowsOptionalFeature>> scan() async {
    final output = await _runner.runPowerShellForOutput(r'''
$features = @(Get-WindowsOptionalFeature -Online -ErrorAction Stop | ForEach-Object {
  [pscustomobject]@{ Name = $_.FeatureName; State = $_.State.ToString() }
})
ConvertTo-Json -Compress -Depth 2 -InputObject $features
''');
    final decoded = jsonDecode(output.isEmpty ? '[]' : output);
    final rows = decoded is List ? decoded : <dynamic>[decoded];
    return rows
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          return WindowsOptionalFeature(
            name: map['Name']! as String,
            state: _state(map['State'] as String?),
          );
        })
        .toList(growable: false)
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  Future<void> setEnabled(String name, bool enabled) async {
    if (!validName.hasMatch(name)) {
      throw StateError('Invalid optional feature identity.');
    }
    final command = enabled
        ? 'Enable-WindowsOptionalFeature'
        : 'Disable-WindowsOptionalFeature';
    await _runner.runPowerShellScript(
      "$command -Online -FeatureName '$name' -NoRestart -ErrorAction Stop | Out-Null",
    );
  }

  static WindowsOptionalFeatureState _state(String? value) => switch (value) {
    'Enabled' => WindowsOptionalFeatureState.enabled,
    'Disabled' => WindowsOptionalFeatureState.disabled,
    'EnablePending' => WindowsOptionalFeatureState.enablePending,
    'DisablePending' => WindowsOptionalFeatureState.disablePending,
    _ => WindowsOptionalFeatureState.unknown,
  };
}
