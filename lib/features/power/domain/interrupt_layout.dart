import '../../../features/drivers/domain/device_identity.dart';
import '../../../platform/windows/hardware_capability_validators.dart';
import '../../../platform/windows/processor_topology.dart';

/// What a device does, for the suggested one-core-per-role layout.
enum InterruptRole { gpu, usb, network, audio }

InterruptRole? interruptRole(PciInterruptCapability capability) {
  final device = capability.device;
  final classGuid = device.classGuid
      .replaceAll(RegExp(r'[{}]'), '')
      .toLowerCase();
  if (device.hardwareIds.any((id) => id.contains(r'&CC_0403'))) {
    return InterruptRole.audio;
  }
  return switch (classGuid) {
    '4d36e968-e325-11ce-bfc1-08002be10318' => InterruptRole.gpu,
    '36fc9e60-c465-11cf-8056-444553540000' => InterruptRole.usb,
    '4d36e972-e325-11ce-bfc1-08002be10318' => InterruptRole.network,
    '4d36e96c-e325-11ce-bfc1-08002be10318' => InterruptRole.audio,
    _ => null,
  };
}

enum InterruptLayoutNote {
  hybridPerformanceOnly,
  cacheGroupChosen,
  sharedNetworkAudio,
}

enum InterruptLayoutUnavailable { unknownTopology, multipleGroups, tooFewCores }

/// One logical processor (the first thread of a physical core) per role.
class InterruptLayout {
  const InterruptLayout({
    this.cpuByRole = const <InterruptRole, ProcessorAddress>{},
    this.notes = const <InterruptLayoutNote>{},
    this.unavailable,
  });

  final Map<InterruptRole, ProcessorAddress> cpuByRole;
  final Set<InterruptLayoutNote> notes;
  final InterruptLayoutUnavailable? unavailable;

  /// `AssignmentSetOverride` for [role], as the affinity operation expects.
  String? maskHex(InterruptRole role) {
    final cpu = cpuByRole[role];
    return cpu == null ? null : (BigInt.one << cpu.number).toRadixString(16);
  }
}

/// Picks the cores from the live topology, never from fixed numbers:
/// outside core 0, P-cores only on hybrid CPUs, and on several L3 groups
/// (dual CCD) the group without the larger cache (no 3D V-Cache), or the
/// one without CPU 0 when they are equal. Up to 6 cores, network and audio
/// share one core.
InterruptLayout planInterruptLayout(ProcessorTopology topology) {
  if (!topology.detailsAvailable) {
    return const InterruptLayout(
      unavailable: InterruptLayoutUnavailable.unknownTopology,
    );
  }
  if (topology.processorsPerGroup.length != 1) {
    return const InterruptLayout(
      unavailable: InterruptLayoutUnavailable.multipleGroups,
    );
  }
  final notes = <InterruptLayoutNote>{};
  final cores = <int, List<ProcessorAddress>>{};
  for (final cpu in topology.addresses.where((item) => item.group == 0)) {
    final core = cpu.coreIndex;
    if (core == null) {
      return const InterruptLayout(
        unavailable: InterruptLayoutUnavailable.unknownTopology,
      );
    }
    cores.putIfAbsent(core, () => <ProcessorAddress>[]).add(cpu);
  }
  final physicalCores = cores.length;
  final firstThreads = <ProcessorAddress>[
    for (final threads in cores.values)
      (threads..sort((a, b) => a.number.compareTo(b.number))).first,
  ];
  final coreZero = cores.entries
      .singleWhere((entry) => entry.value.any((cpu) => cpu.number == 0))
      .key;
  var candidates = firstThreads
      .where((cpu) => cpu.coreIndex != coreZero)
      .toList();
  if (topology.hasHeterogeneousCores) {
    final performance = topology.performanceCores;
    candidates = candidates.where(performance.contains).toList();
    notes.add(InterruptLayoutNote.hybridPerformanceOnly);
  }
  final caches = topology.addressesByLastLevelCache(0);
  if (caches.length > 1) {
    final sizes = topology.lastLevelCacheBytes;
    final cacheOfCpuZero = topology.addresses
        .firstWhere((cpu) => cpu.group == 0 && cpu.number == 0)
        .lastLevelCacheIndex;
    final known = caches.keys.every(sizes.containsKey);
    final smallest = known
        ? caches.keys.map((key) => sizes[key]!).reduce((a, b) => a < b ? a : b)
        : null;
    final allEqual =
        known && caches.keys.every((key) => sizes[key] == smallest);
    final chosen = caches.keys.where(
      (key) =>
          known && !allEqual ? sizes[key] == smallest : key != cacheOfCpuZero,
    );
    if (chosen.isNotEmpty) {
      final keep = chosen.first;
      candidates = candidates
          .where((cpu) => cpu.lastLevelCacheIndex == keep)
          .toList();
      notes.add(InterruptLayoutNote.cacheGroupChosen);
    }
  }
  // Highest cores first: games tend to run on the lowest, preferred cores.
  candidates.sort((a, b) => b.number.compareTo(a.number));
  final shared = physicalCores <= 6 || candidates.length < 4;
  if (candidates.length < 3) {
    return const InterruptLayout(
      unavailable: InterruptLayoutUnavailable.tooFewCores,
    );
  }
  if (shared) notes.add(InterruptLayoutNote.sharedNetworkAudio);
  return InterruptLayout(
    cpuByRole: <InterruptRole, ProcessorAddress>{
      InterruptRole.gpu: candidates[0],
      InterruptRole.usb: candidates[1],
      InterruptRole.network: candidates[2],
      InterruptRole.audio: shared ? candidates[2] : candidates[3],
    },
    notes: notes,
  );
}
