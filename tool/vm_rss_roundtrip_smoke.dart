import 'dart:convert';
import 'dart:io';

import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

Future<void> main() async {
  final output = await ProcessRunner.shared.runPowerShellForOutput(
    r"@(Get-NetAdapter -Physical | Where-Object Status -ne 'Disabled' | Select-Object -ExpandProperty Name) | ConvertTo-Json -Compress",
  );
  final decoded = jsonDecode(output);
  final names = decoded is List
      ? decoded.cast<String>()
      : <String>[decoded as String];
  final service = WindowsRssService();
  for (final name in names) {
    try {
      final before = await service.inspect(name);
      final current = before.configuration;
      final changed = RssConfiguration(
        enabled: !current.enabled,
        profile: current.profile,
        baseProcessor: current.baseProcessor,
        maximumProcessor: current.maximumProcessor,
        processorCount: current.processorCount,
        queueCount: current.queueCount,
        processorArray: current.processorArray,
      );
      try {
        await service.write(name, changed);
        final applied = await service.inspect(name);
        if (applied.configuration.enabled != changed.enabled) {
          throw StateError('RSS mutation read-back failed.');
        }
        stdout.writeln('APPLIED=${applied.toJson()}');
      } finally {
        await service.write(name, current);
      }
      final restored = await service.inspect(name);
      if (restored.toJson().toString() != before.toJson().toString()) {
        throw StateError('RSS full-tuple rollback failed.');
      }
      stdout.writeln('RESTORED=${restored.toJson()}');
      stdout.writeln('CLEAN=true');
      return;
    } catch (error) {
      stderr.writeln('$name: $error');
    }
  }
  throw StateError('No adapter completed the RSS round trip.');
}
