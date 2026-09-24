import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/platform/windows/hardware_capability_validators.dart';

void main() {
  test('RSS values outside live topology are rejected', () {
    final cpu0 = const ProcessorAddress(0, 0, numaNode: 0);
    final cpu1 = const ProcessorAddress(0, 1, numaNode: 0);
    final capabilities = RssCapabilities(
      processors: <ProcessorAddress>{cpu0, cpu1},
      maximumQueues: 2,
      maximumProcessors: 2,
      nicNumaNode: 0,
    );

    expect(
      HardwareCapabilityValidators.validateRss(
        RssConfiguration(
          enabled: true,
          profile: 'Closest',
          baseProcessor: cpu0,
          maximumProcessor: cpu1,
          processorCount: 2,
          queueCount: 3,
          processorArray: <ProcessorAddress>[cpu0, cpu1],
        ),
        capabilities,
      ),
      isNotNull,
    );
  });

  test('MSI limits and processor masks are never truncated', () {
    expect(
      HardwareCapabilityValidators.validateMsiMessageCount(
        msiSupported: true,
        requested: 9,
        hardwareMaximum: 8,
      ),
      isNotNull,
    );
    expect(
      HardwareCapabilityValidators.validateAffinity(
        processorGroup: 0,
        mask: BigInt.one << 64,
        logicalProcessorsPerGroup: const <int, int>{0: 64},
      ),
      contains('without truncation'),
    );
  });
}
