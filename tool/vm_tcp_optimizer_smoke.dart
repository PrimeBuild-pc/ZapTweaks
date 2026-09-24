import 'dart:io';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/tcp_optimizer_operations.dart';
import 'package:script_utility/platform/windows/tcp_optimizer_service.dart';

Future<void> main() async {
  final tcpStore = WindowsTcpOptimizerService();
  final tcpOperation = TcpSettingOperation(tcpStore);
  final settings = await tcpStore.inventory();
  bool mutable(TcpSettingState item) =>
      item.writable && item.supportedValues.any((value) => value != item.value);
  final setting = settings.firstWhere(
    (item) =>
        item.target.startsWith('template:InternetCustom:') && mutable(item),
    orElse: () => settings.firstWhere(mutable),
  );
  final desired = setting.supportedValues.firstWhere(
    (value) => value != setting.value,
  );
  final tcpRequest = OperationRequest(
    operationId: tcpOperation.id,
    target: setting.target,
    desiredValue: desired,
  );
  final support = await tcpOperation.supports(
    const OperationContext(windowsBuild: 26100, edition: 'Pro'),
    tcpRequest,
  );
  if (!support.supported) {
    throw StateError(support.reason ?? 'TCP setting is unsupported.');
  }
  final tcpSnapshot = await tcpOperation.captureSnapshot(tcpRequest);
  try {
    await tcpOperation.apply(tcpRequest);
    final applied = await tcpOperation.verify(tcpRequest);
    if (applied.value != desired) throw StateError('TCP read-back failed.');
    stdout.writeln('TCP_APPLIED=${setting.target}:$desired');
  } finally {
    await tcpOperation.rollback(tcpRequest, tcpSnapshot);
  }
  final tcpRestored = await tcpOperation.inspect(tcpRequest);
  if (!tcpRestored.sameValue(tcpSnapshot.expectedAfterRollback)) {
    throw StateError('TCP exact rollback failed.');
  }
  stdout.writeln('TCP_RESTORED=${tcpRestored.value}');

  final qosStore = WindowsQosPolicyService();
  final qosOperation = QosPolicyOperation(qosStore);
  const policy = QosPolicy(
    name: 'ZapTweaks - VM Smoke',
    appPath: r'C:\Windows\System32\ping.exe',
    protocol: 'TCP',
    dscp: 8,
  );
  if (await qosStore.inspect(policy.name) != null) {
    throw StateError('Reserved VM smoke QoS policy already exists.');
  }
  final qosRequest = OperationRequest(
    operationId: qosOperation.id,
    target: policy.name,
    desiredValue: policy.toJson(),
  );
  final qosSnapshot = await qosOperation.captureSnapshot(qosRequest);
  try {
    await qosOperation.apply(qosRequest);
    final applied = await qosOperation.verify(qosRequest);
    if (applied.kind != OperationStateKind.configured) {
      throw StateError('QoS read-back failed.');
    }
    stdout.writeln('QOS_APPLIED=${applied.value}');

    const updated = QosPolicy(
      name: 'ZapTweaks - VM Smoke',
      appPath: r'C:\Windows\System32\ping.exe',
      protocol: 'TCP',
      dscp: 10,
    );
    final updateRequest = OperationRequest(
      operationId: qosOperation.id,
      target: updated.name,
      desiredValue: updated.toJson(),
    );
    final presentSnapshot = await qosOperation.captureSnapshot(updateRequest);
    try {
      await qosOperation.apply(updateRequest);
      if ((await qosOperation.verify(updateRequest)).value.toString() !=
          updated.toJson().toString()) {
        throw StateError('QoS update read-back failed.');
      }
    } finally {
      await qosOperation.rollback(updateRequest, presentSnapshot);
    }
    if ((await qosOperation.inspect(updateRequest)).value.toString() !=
        policy.toJson().toString()) {
      throw StateError('QoS present-policy rollback failed.');
    }
    stdout.writeln('QOS_PRESENT_ROLLBACK=true');
  } finally {
    await qosOperation.rollback(qosRequest, qosSnapshot);
  }
  if ((await qosOperation.inspect(qosRequest)).kind !=
      OperationStateKind.absent) {
    throw StateError('QoS absent-policy rollback failed.');
  }
  stdout.writeln('QOS_RESTORED=absent');
  stdout.writeln('CLEAN=true');
}
