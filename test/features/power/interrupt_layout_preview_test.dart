import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/features/power/application/interrupt_layout_preview.dart';
import 'package:script_utility/features/power/domain/interrupt_layout.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/interrupt_configuration_service.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

PciInterruptCapability _device(
  String id,
  String classGuid, {
  int? bus,
  int? address,
  bool audioInUse = true,
  Set<String> hardwareIds = const <String>{},
}) => PciInterruptCapability(
  device: DeviceIdentity(
    instanceId: id,
    classGuid: classGuid,
    description: id,
    hardwareIds: hardwareIds,
    driverKey: null,
    driverInf: null,
  ),
  lineBased: false,
  msi: true,
  msiX: true,
  messageMaximum: 4,
  busNumber: bus,
  address: address,
  audioInUse: audioInUse,
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

  test('the audio core skips GPU audio and unused controllers', () {
    const display = '4d36e968-e325-11ce-bfc1-08002be10318';
    const system = '4d36e97d-e325-11ce-bfc1-08002be10318';
    const hda = <String>{r'PCI\VEN_1002&CC_0403'};
    PciInterruptCapability audio(
      String id, {
      int address = 1,
      bool inUse = true,
    }) => _device(
      id,
      system,
      bus: 48,
      address: address,
      audioInUse: inUse,
      hardwareIds: hda,
    );
    List<LayoutRow> rows(List<PciInterruptCapability> audioDevices) =>
        buildLayoutRows(
          layout: layout,
          devices: [
            _device(r'PCI\VEN_1002&DEV_73A5\GPU', display, bus: 48, address: 0),
            ...audioDevices,
          ],
          configurations: const {},
          rssByInstanceId: const {},
        );

    // Radeon HDMI/DP audio: function 1 of the GPU slot, same vendor.
    final gpuAudio = rows([audio(r'PCI\VEN_1002&DEV_AB28\HDMI')]);
    expect(gpuAudio.last.skip, LayoutSkip.gpuAudio);
    expect(gpuAudio.last.request, isNull);
    expect(hasLayoutAudio(gpuAudio), isFalse);

    // APU: onboard HD Audio shares the slot but not the vendor.
    final onboard = rows([audio(r'PCI\VEN_1022&DEV_15E3\HDA', address: 6)]);
    expect(onboard.last.status, LayoutRowStatus.toDo);
    expect(hasLayoutAudio(onboard), isTrue);

    // Realtek disabled by a user who plays with a USB DAC.
    final unused = rows([
      audio(r'PCI\VEN_1022&DEV_1487\HDA', address: 0x10003, inUse: false),
    ]);
    expect(unused.last.skip, LayoutSkip.audioUnused);
    expect(hasLayoutAudio(unused), isFalse);
  });
}
