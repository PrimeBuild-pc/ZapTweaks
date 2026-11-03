import '../../../core/operations/operation.dart';
import '../../../features/drivers/domain/device_identity.dart';
import '../../../platform/windows/hardware_capability_validators.dart';
import '../../../platform/windows/interrupt_configuration_service.dart';
import '../../../platform/windows/rss_service.dart';
import '../domain/interrupt_layout.dart';

enum LayoutRowStatus { toDo, alreadySet, skipped }

enum LayoutSkip { rssOff, rssUnreadable, rssManual }

/// One line of the preview: a device's interrupt affinity or a network
/// adapter's RSS start processor.
class LayoutRow {
  const LayoutRow({
    required this.label,
    required this.role,
    required this.cpu,
    required this.status,
    this.request,
    this.rss = false,
    this.msiOff = false,
    this.skip,
    this.rssBase,
  });

  final String label;
  final InterruptRole role;
  final ProcessorAddress cpu;
  final LayoutRowStatus status;
  final OperationRequest? request;
  final bool rss;
  final bool msiOff;
  final LayoutSkip? skip;

  /// Current RSS start processor, for RSS rows.
  final int? rssBase;
}

/// Rows for the suggested layout; [rssByInstanceId] holds the RSS state of
/// each network device (null when it could not be read).
List<LayoutRow> buildLayoutRows({
  required InterruptLayout layout,
  required List<PciInterruptCapability> devices,
  required Map<String, DeviceInterruptConfiguration> configurations,
  required Map<String, RssAdapterState?> rssByInstanceId,
}) {
  final rows = <LayoutRow>[];
  for (final device in devices) {
    final role = interruptRole(device);
    final cpu = role == null ? null : layout.cpuByRole[role];
    if (role == null || cpu == null) continue;
    final id = device.device.instanceId;
    final current = configurations[id];
    final mask = layout.maskHex(role)!;
    final done =
        current?.devicePolicy == 4 &&
        BigInt.tryParse(current?.assignmentMaskHex ?? '', radix: 16) ==
            BigInt.parse(mask, radix: 16);
    rows.add(
      LayoutRow(
        label: device.device.description,
        role: role,
        cpu: cpu,
        status: done ? LayoutRowStatus.alreadySet : LayoutRowStatus.toDo,
        msiOff: current?.msiSupported != 1,
        request: done
            ? null
            : OperationRequest(
                operationId: 'device.interrupt_affinity.configure',
                target: id,
                desiredValue: <String, Object>{
                  'devicePolicy': 4,
                  'processorGroup': 0,
                  'maskHex': mask,
                },
              ),
      ),
    );
    if (role == InterruptRole.network && rssByInstanceId.containsKey(id)) {
      rows.add(_rssRow(rssByInstanceId[id], cpu));
    }
  }
  return rows;
}

/// RSS is shown, never changed: moving its start makes Windows re-fit the
/// queue and processor counts, which the RSS operation cannot undo exactly
/// (seen in the VM on 03/11/2026).
LayoutRow _rssRow(RssAdapterState? state, ProcessorAddress cpu) {
  LayoutRow row(String label, LayoutRowStatus status, [LayoutSkip? skip]) =>
      LayoutRow(
        label: label,
        role: InterruptRole.network,
        cpu: cpu,
        status: status,
        rss: true,
        skip: skip,
        rssBase: state?.configuration.baseProcessor.number,
      );
  if (state == null) {
    return row('', LayoutRowStatus.skipped, LayoutSkip.rssUnreadable);
  }
  final value = state.configuration;
  if (!value.enabled) {
    return row(state.name, LayoutRowStatus.skipped, LayoutSkip.rssOff);
  }
  return value.baseProcessor.group == 0 &&
          value.baseProcessor.number == cpu.number
      ? row(state.name, LayoutRowStatus.alreadySet)
      : row(state.name, LayoutRowStatus.skipped, LayoutSkip.rssManual);
}
