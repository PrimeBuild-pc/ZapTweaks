// Read-only: prints the suggested interrupt layout for this PC.
import 'dart:io';

import 'package:script_utility/core/operations/device_msi_operation.dart';
import 'package:script_utility/features/drivers/application/setupapi_device_inventory_service.dart';
import 'package:script_utility/features/power/application/interrupt_layout_preview.dart';
import 'package:script_utility/features/power/domain/interrupt_layout.dart';
import 'package:script_utility/platform/windows/interrupt_configuration_service.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

Future<void> main() async {
  final topology = ProcessorTopology.inspect();
  stdout.writeln(
    'CPUs ${topology.logicalProcessorCount}, groups ${topology.processorsPerGroup}, '
    'L3 ${topology.lastLevelCacheBytes.map((k, v) => MapEntry(k, '${v >> 20} MiB'))}, '
    'hybrid ${topology.hasHeterogeneousCores}, SMT ${topology.hasSmt}',
  );
  final layout = planInterruptLayout(topology);
  stdout.writeln('Unavailable: ${layout.unavailable}, notes: ${layout.notes}');
  layout.cpuByRole.forEach(
    (role, cpu) =>
        stdout.writeln('  $role -> CPU ${cpu.number} (core ${cpu.coreIndex})'),
  );
  final devices = const SetupApiDeviceInventoryService()
      .scanPciInterruptCapabilities()
      .where(isAllowedInterruptDevice)
      .toList();
  const reader = InterruptConfigurationService(WindowsRegistryValueStore());
  final configurations = {
    for (final device in devices)
      device.device.instanceId: await reader.read(device),
  };
  final service = WindowsRssService();
  final names = await service.adapterNamesByInstanceId();
  final rssCapable = (await service.adapterNames()).toSet();
  final rss = <String, RssAdapterState?>{};
  for (final device in devices) {
    final name = names[device.device.instanceId.toUpperCase()];
    if (name != null && rssCapable.contains(name)) {
      rss[device.device.instanceId] = await service.inspect(name);
    }
  }
  for (final row in buildLayoutRows(
    layout: layout,
    devices: devices,
    configurations: configurations,
    rssByInstanceId: rss,
  )) {
    stdout.writeln(
      '${row.status.name.padRight(10)} ${row.rss ? 'RSS ' : ''}${row.label} '
      '-> CPU ${row.cpu.number}${row.msiOff && !row.rss ? ' (MSI off)' : ''}'
      '${row.skip == null ? '' : ' skip ${row.skip!.name}'} ${row.request?.desiredValue ?? ''}',
    );
  }
}
