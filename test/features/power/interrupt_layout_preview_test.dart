import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/features/power/application/interrupt_layout_preview.dart';
import 'package:script_utility/features/power/domain/interrupt_layout.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/interrupt_configuration_service.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

PciInterruptCapability _device(String id, String classGuid) =>
    PciInterruptCapability(
      device: DeviceIdentity(
        instanceId: id,
        classGuid: classGuid,
        description: id,
        hardwareIds: const <String>{},
        driverKey: null,
        driverInf: null,
      ),
      lineBased: false,
      msi: true,
      msiX: true,
      messageMaximum: 4,
    );

RssAdapterState _rss({bool enabled = true, int base = 0}) => RssAdapterState(
  name: 'Ethernet',
  configuration: RssConfiguration(
    enabled: enabled,
    profile: 'Closest',
    baseProcessor: ProcessorAddress(0, base),
    maximumProcessor: const ProcessorAddress(0, 15),
    processorCount: 4,
    queueCount: 4,
    processorArray: const <ProcessorAddress>[ProcessorAddress(0, 0)],
  ),
  maximumQueues: 4,
  maximumProcessors: 4,
);

void main() {
  const gpu = r'PCI\GPU';
  const nic = r'PCI\NIC';
  const layout = InterruptLayout(
    cpuByRole: {
      InterruptRole.gpu: ProcessorAddress(0, 14),
      InterruptRole.usb: ProcessorAddress(0, 12),
      InterruptRole.network: ProcessorAddress(0, 10),
      InterruptRole.audio: ProcessorAddress(0, 8),
    },
  );
  final devices = [
    _device(gpu, '4d36e968-e325-11ce-bfc1-08002be10318'),
    _device(nic, '4d36e972-e325-11ce-bfc1-08002be10318'),
  ];

  test('to do and already set come from the live configuration', () {
    final rows = buildLayoutRows(
      layout: layout,
      devices: devices,
      configurations: const {
        gpu: DeviceInterruptConfiguration(
          msiSupported: 1,
          messageNumberLimit: 1,
          devicePriority: null,
          devicePolicy: 4,
          assignmentMaskHex: '4000',
        ),
      },
      rssByInstanceId: const {},
    );
    expect(rows.map((row) => row.status), [
      LayoutRowStatus.alreadySet,
      LayoutRowStatus.toDo,
    ]);
    expect(rows.first.request, isNull);
    final affinity = rows[1].request!;
    expect(affinity.operationId, 'device.interrupt_affinity.configure');
    expect(affinity.desiredValue, {
      'devicePolicy': 4,
      'processorGroup': 0,
      'maskHex': '400',
    });
    expect(rows[1].msiOff, isTrue);
  });

  test('RSS is only shown, never changed', () {
    LayoutRow rssRow(RssAdapterState? state) => buildLayoutRows(
      layout: layout,
      devices: devices,
      configurations: const {},
      rssByInstanceId: {nic: state},
    ).last;
    for (final state in [_rss(), _rss(enabled: false), null, _rss(base: 10)]) {
      expect(rssRow(state).rss, isTrue);
      expect(rssRow(state).request, isNull);
    }
    expect(rssRow(_rss()).skip, LayoutSkip.rssManual);
    expect(rssRow(_rss()).rssBase, 0);
    expect(rssRow(_rss(enabled: false)).skip, LayoutSkip.rssOff);
    expect(rssRow(null).skip, LayoutSkip.rssUnreadable);
    expect(rssRow(_rss(base: 10)).status, LayoutRowStatus.alreadySet);
  });
}
