import 'dart:io';

import 'package:script_utility/core/operations/driver_update_policy_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/drivers/application/driver_update_policy_store.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final marker = DriverUpdatePolicyStore(
    path: '${Directory.systemTemp.path}\\zaptweaks-driver-policy-smoke.json',
  );
  await marker.clear();
  final operation = DriverUpdatePolicyOperation(
    registry: const WindowsRegistryValueStore(),
    policyStore: marker,
  );
  final request = OperationRequest(
    operationId: operation.id,
    desiredValue: 1,
    parameters: <String, Object?>{
      'expiresAt': DateTime.now()
          .toUtc()
          .add(const Duration(days: 7))
          .toIso8601String(),
    },
  );
  final support = await operation.supports(
    const OperationContext(windowsBuild: 26100, edition: 'Pro'),
    request,
  );
  if (!support.supported) {
    throw StateError(support.reason ?? 'Unsupported driver policy operation.');
  }
  final snapshot = await operation.captureSnapshot(request);
  try {
    await operation.apply(request);
    final applied = await operation.verify(request);
    if (applied.kind != OperationStateKind.configured || applied.value != 1) {
      throw StateError('Apply verification failed: ${applied.toJson()}');
    }
    stdout.writeln('APPLIED=${applied.toJson()}');
  } finally {
    await operation.rollback(request, snapshot);
    final restored = await operation.inspect(request);
    if (!restored.sameValue(snapshot.expectedAfterRollback)) {
      throw StateError('Rollback verification failed: ${restored.toJson()}');
    }
    await marker.clear();
    stdout.writeln('RESTORED=${restored.toJson()}');
  }
}
