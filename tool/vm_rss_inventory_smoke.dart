import 'dart:convert';
import 'dart:io';

import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final output = await ProcessRunner.shared.runPowerShellForOutput(
    r"@(Get-NetAdapter -Physical | Where-Object Status -ne 'Disabled' | Select-Object -ExpandProperty Name) | ConvertTo-Json -Compress",
  );
  final decoded = jsonDecode(output);
  final candidates = decoded is List
      ? decoded.cast<String>()
      : decoded is String
      ? <String>[decoded]
      : const <String>[];
  final service = WindowsRssService();
  for (final name in candidates) {
    try {
      stdout.writeln((await service.inspect(name)).toJson());
      return;
    } catch (_) {}
  }
  throw StateError('No physical adapter exposed the RSS provider.');
}
