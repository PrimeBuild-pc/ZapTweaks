import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';

void main() {
  test('native topology preserves every Windows processor group', () {
    final topology = ProcessorTopology.inspect();

    expect(topology.processorsPerGroup, isNotEmpty);
    expect(topology.logicalProcessorCount, topology.addresses.length);
    expect(topology.detailsAvailable, isTrue);
    expect(
      topology.addresses.every(
        (item) =>
            item.coreIndex != null &&
            item.lastLevelCacheIndex != null &&
            item.efficiencyClass != null,
      ),
      isTrue,
    );
    for (final entry in topology.processorsPerGroup.entries) {
      expect(
        HardwareCapabilityValidators.validateAffinity(
          processorGroup: entry.key,
          mask: (BigInt.one << entry.value) - BigInt.one,
          logicalProcessorsPerGroup: topology.processorsPerGroup,
        ),
        isNull,
      );
    }
  });

  test('topology derives SMT, P/E-core, LLC and NUMA selections', () {
    final topology = ProcessorTopology(
      processorsPerGroup: const <int, int>{0: 8},
      processors: <ProcessorAddress>{
        ProcessorAddress(
          0,
          0,
          coreIndex: 0,
          lastLevelCacheIndex: 0,
          numaNode: 0,
          efficiencyClass: 1,
        ),
        ProcessorAddress(
          0,
          1,
          coreIndex: 0,
          lastLevelCacheIndex: 0,
          numaNode: 0,
          efficiencyClass: 1,
        ),
        ProcessorAddress(
          0,
          2,
          coreIndex: 1,
          lastLevelCacheIndex: 0,
          numaNode: 0,
          efficiencyClass: 1,
        ),
        ProcessorAddress(
          0,
          3,
          coreIndex: 1,
          lastLevelCacheIndex: 0,
          numaNode: 0,
          efficiencyClass: 1,
        ),
        ProcessorAddress(
          0,
          4,
          coreIndex: 2,
          lastLevelCacheIndex: 1,
          numaNode: 1,
          efficiencyClass: 0,
        ),
        ProcessorAddress(
          0,
          5,
          coreIndex: 2,
          lastLevelCacheIndex: 1,
          numaNode: 1,
          efficiencyClass: 0,
        ),
        ProcessorAddress(
          0,
          6,
          coreIndex: 3,
          lastLevelCacheIndex: 1,
          numaNode: 1,
          efficiencyClass: 0,
        ),
        ProcessorAddress(
          0,
          7,
          coreIndex: 3,
          lastLevelCacheIndex: 1,
          numaNode: 1,
          efficiencyClass: 0,
        ),
      },
    );

    expect(topology.hasSmt, isTrue);
    expect(topology.hasHeterogeneousCores, isTrue);
    expect(topology.primaryThreads.map((item) => item.number), <int>{
      0,
      2,
      4,
      6,
    });
    expect(topology.performanceCores.map((item) => item.number), <int>{
      0,
      1,
      2,
      3,
    });
    expect(topology.efficiencyCores.map((item) => item.number), <int>{
      4,
      5,
      6,
      7,
    });
    expect(topology.addressesByLastLevelCache(0).keys, <int>{0, 1});
    expect(topology.addressesByNumaNode(0).keys, <int>{0, 1});
  });
}
