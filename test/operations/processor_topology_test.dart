import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';

void main() {
  test('native topology preserves every Windows processor group', () {
    final topology = ProcessorTopology.inspect();

    expect(topology.processorsPerGroup, isNotEmpty);
    expect(topology.logicalProcessorCount, topology.addresses.length);
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
}
