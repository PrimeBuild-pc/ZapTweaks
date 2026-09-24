import 'dart:io';

import 'package:script_utility/core/operations/device_msi_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/drivers/application/setupapi_device_inventory_service.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

Future<void> main() async {
  final inventory = const SetupApiDeviceInventoryService();
  final capabilities = inventory.scanPciInterruptCapabilities();
  for (final capability in capabilities.where(
    (item) => item.msi || item.msiX,
  )) {
    final operation = DeviceMsiOperation(
      registry: WindowsRegistryValueStore(),
      inventory: () => capabilities,
    );
    final probe = OperationRequest(
      operationId: operation.id,
      target: capability.device.instanceId,
      desiredValue: const <String, Object?>{
        'msiSupported': 1,
        'messageNumberLimit': 1,
      },
    );
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      probe,
    );
    if (!support.supported) continue;
    final before = await operation.inspect(probe);
    final current = Map<String, Object?>.from(before.value! as Map);
    final enabled = current['msiSupported'] == 1;
    final request = OperationRequest(
      operationId: operation.id,
      target: capability.device.instanceId,
      desiredValue: enabled
          ? const <String, Object?>{
              'msiSupported': 0,
              'messageNumberLimit': null,
            }
          : const <String, Object?>{'msiSupported': 1, 'messageNumberLimit': 1},
    );
    final snapshot = await operation.captureSnapshot(request);
    try {
      await operation.apply(request);
      stdout.writeln('APPLIED=${(await operation.verify(request)).value}');
    } finally {
      await operation.rollback(request, snapshot);
    }
    final restored = await operation.inspect(request);
    if (!restored.sameValue(snapshot.expectedAfterRollback)) {
      throw StateError('MSI rollback mismatch.');
    }
    stdout.writeln('DEVICE=${capability.device.instanceId}');
    stdout.writeln('RESTORED=${restored.value}');
    stdout.writeln('CLEAN=true');
    return;
  }
  throw StateError(
    'No safe MSI-capable display, network, or media device was available.',
  );
}
