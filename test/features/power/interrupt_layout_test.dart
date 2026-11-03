import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/features/power/domain/interrupt_layout.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';

/// [cores] physical cores, [smt] threads each, CPU numbers in core order.
ProcessorTopology _topology(
  int cores, {
  int smt = 2,
  int Function(int core)? cache,
  int Function(int core)? efficiency,
  Map<int, int> cacheBytes = const <int, int>{},
}) {
  final processors = <ProcessorAddress>{
    for (var core = 0; core < cores; core++)
      for (var thread = 0; thread < smt; thread++)
        ProcessorAddress(
          0,
          core * smt + thread,
          coreIndex: core,
          lastLevelCacheIndex: cache?.call(core) ?? 0,
          efficiencyClass: efficiency?.call(core) ?? 0,
        ),
  };
  return ProcessorTopology(
    processorsPerGroup: <int, int>{0: processors.length},
    processors: processors,
    lastLevelCacheBytes: cacheBytes,
  );
}

Map<InterruptRole, int> _cpus(InterruptLayout layout) => <InterruptRole, int>{
  for (final entry in layout.cpuByRole.entries) entry.key: entry.value.number,
};

void main() {
  test('8 cores with SMT: one first thread per role, never core 0', () {
    final layout = planInterruptLayout(_topology(8));
    expect(_cpus(layout), <InterruptRole, int>{
      InterruptRole.gpu: 14,
      InterruptRole.usb: 12,
      InterruptRole.network: 10,
      InterruptRole.audio: 8,
    });
    expect(layout.notes, isEmpty);
    expect(layout.maskHex(InterruptRole.gpu), '4000');
  });

  test('6 cores or fewer: network and audio share a core', () {
    final layout = planInterruptLayout(_topology(6));
    expect(layout.cpuByRole[InterruptRole.network]!.number, 6);
    expect(layout.cpuByRole[InterruptRole.audio]!.number, 6);
    expect(layout.notes, contains(InterruptLayoutNote.sharedNetworkAudio));
    final four = planInterruptLayout(_topology(4, smt: 1));
    expect(_cpus(four).values, isNot(contains(0)));
    expect(four.notes, contains(InterruptLayoutNote.sharedNetworkAudio));
  });

  test('SMT off uses every core but core 0', () {
    expect(_cpus(planInterruptLayout(_topology(8, smt: 1))), {
      InterruptRole.gpu: 7,
      InterruptRole.usb: 6,
      InterruptRole.network: 5,
      InterruptRole.audio: 4,
    });
  });

  test('Intel hybrid: P-cores only, never an E-core', () {
    // 8 P-cores with SMT (CPU 0-15), then 16 E-cores without SMT.
    final processors = <ProcessorAddress>{
      for (var cpu = 0; cpu < 16; cpu++)
        ProcessorAddress(
          0,
          cpu,
          coreIndex: cpu ~/ 2,
          lastLevelCacheIndex: 0,
          efficiencyClass: 1,
        ),
      for (var cpu = 16; cpu < 32; cpu++)
        ProcessorAddress(
          0,
          cpu,
          coreIndex: cpu - 8,
          lastLevelCacheIndex: 0,
          efficiencyClass: 0,
        ),
    };
    final layout = planInterruptLayout(
      ProcessorTopology(processorsPerGroup: {0: 32}, processors: processors),
    );
    expect(_cpus(layout).values.every((cpu) => cpu < 16 && cpu > 1), isTrue);
    expect(_cpus(layout)[InterruptRole.gpu], 14);
    expect(layout.notes, contains(InterruptLayoutNote.hybridPerformanceOnly));
  });

  test('dual CCD with 3D V-Cache: devices on the CCD without it', () {
    final x3d = _topology(
      16,
      cache: (core) => core < 8 ? 0 : 1,
      cacheBytes: const {0: 96 << 20, 1: 32 << 20},
    );
    expect(_cpus(planInterruptLayout(x3d)), {
      InterruptRole.gpu: 30,
      InterruptRole.usb: 28,
      InterruptRole.network: 26,
      InterruptRole.audio: 24,
    });
    // V-Cache on the second CCD: devices go to the first one, still not core 0.
    final swapped = _topology(
      16,
      cache: (core) => core < 8 ? 0 : 1,
      cacheBytes: const {0: 32 << 20, 1: 96 << 20},
    );
    final cpus = _cpus(planInterruptLayout(swapped)).values;
    expect(cpus.every((cpu) => cpu < 16 && cpu >= 2), isTrue);
  });

  test('dual CCD with equal caches: the CCD without CPU 0', () {
    final layout = planInterruptLayout(
      _topology(
        16,
        cache: (core) => core < 8 ? 0 : 1,
        cacheBytes: const {0: 32 << 20, 1: 32 << 20},
      ),
    );
    expect(_cpus(layout).values.every((cpu) => cpu >= 16), isTrue);
    expect(layout.notes, contains(InterruptLayoutNote.cacheGroupChosen));
  });

  test('refuses what it cannot represent safely', () {
    expect(
      planInterruptLayout(_topology(2)).unavailable,
      InterruptLayoutUnavailable.tooFewCores,
    );
    expect(
      planInterruptLayout(
        const ProcessorTopology(processorsPerGroup: {0: 64, 1: 64}),
      ).unavailable,
      InterruptLayoutUnavailable.unknownTopology,
    );
    final twoGroups = ProcessorTopology(
      processorsPerGroup: const {0: 2, 1: 2},
      processors: {
        for (var group = 0; group < 2; group++)
          for (var cpu = 0; cpu < 2; cpu++)
            ProcessorAddress(group, cpu, coreIndex: cpu),
      },
    );
    expect(
      planInterruptLayout(twoGroups).unavailable,
      InterruptLayoutUnavailable.multipleGroups,
    );
  });

  test('roles come from the device class', () {
    PciInterruptCapability device(
      String classGuid, [
      List<String> ids = const [],
    ]) => PciInterruptCapability(
      device: DeviceIdentity(
        instanceId: r'PCI\X',
        classGuid: classGuid,
        description: 'x',
        hardwareIds: ids.toSet(),
        driverKey: null,
        driverInf: null,
      ),
      lineBased: false,
      msi: true,
      msiX: false,
      messageMaximum: 1,
    );
    expect(
      interruptRole(device('{4D36E968-E325-11CE-BFC1-08002BE10318}')),
      InterruptRole.gpu,
    );
    expect(
      interruptRole(device('36fc9e60-c465-11cf-8056-444553540000')),
      InterruptRole.usb,
    );
    expect(
      interruptRole(device('4d36e972-e325-11ce-bfc1-08002be10318')),
      InterruptRole.network,
    );
    expect(
      interruptRole(
        device('{00000000-0000-0000-0000-000000000000}', [
          r'PCI\VEN_1002&DEV_AB30&CC_0403',
        ]),
      ),
      InterruptRole.audio,
    );
  });

  test('parses L3 sizes from cache records', () {
    // One unified L3 record of 32 MiB covering CPU 0-3 in group 0.
    final record = ByteDataBuilder.cacheRecord(
      level: 3,
      bytes: 32 << 20,
      mask: 0xf,
    );
    final sizes = ProcessorTopology.parseLastLevelCacheBytes(record, {
      for (var cpu = 0; cpu < 4; cpu++)
        ProcessorAddress(0, cpu, lastLevelCacheIndex: 5),
    });
    expect(sizes, {5: 32 << 20});
  });
}

abstract final class ByteDataBuilder {
  static ByteData cacheRecord({
    required int level,
    required int bytes,
    required int mask,
  }) {
    final data = ByteData(56);
    data
      ..setUint32(0, 2, Endian.little) // RelationCache
      ..setUint32(4, 56, Endian.little)
      ..setUint8(8, level)
      ..setUint32(12, bytes, Endian.little)
      ..setUint32(16, 0, Endian.little) // CacheUnified
      ..setUint16(38, 1, Endian.little)
      ..setUint64(40, mask, Endian.little)
      ..setUint16(48, 0, Endian.little);
    return data;
  }
}
