class ProcessorAddress {
  const ProcessorAddress(
    this.group,
    this.number, {
    this.numaNode,
    this.coreIndex,
    this.lastLevelCacheIndex,
    this.efficiencyClass,
    this.parked = false,
  });

  final int group;
  final int number;
  final int? numaNode;
  final int? coreIndex;
  final int? lastLevelCacheIndex;
  final int? efficiencyClass;
  final bool parked;

  @override
  bool operator ==(Object other) =>
      other is ProcessorAddress &&
      group == other.group &&
      number == other.number;

  @override
  int get hashCode => Object.hash(group, number);
}

class RssCapabilities {
  const RssCapabilities({
    required this.processors,
    required this.maximumQueues,
    required this.maximumProcessors,
    this.nicNumaNode,
  });

  final Set<ProcessorAddress> processors;
  final int maximumQueues;
  final int maximumProcessors;
  final int? nicNumaNode;
}

class RssConfiguration {
  const RssConfiguration({
    required this.enabled,
    required this.profile,
    required this.baseProcessor,
    required this.maximumProcessor,
    required this.processorCount,
    required this.queueCount,
    required this.processorArray,
  });

  final bool enabled;
  final String profile;
  final ProcessorAddress baseProcessor;
  final ProcessorAddress maximumProcessor;
  final int processorCount;
  final int queueCount;
  final List<ProcessorAddress> processorArray;
}

class HardwareCapabilityValidators {
  static String? validateRss(
    RssConfiguration value,
    RssCapabilities capabilities,
  ) {
    if (!value.enabled) return null;
    if (value.queueCount < 1 || value.queueCount > capabilities.maximumQueues) {
      return 'RSS queue count is outside adapter capabilities.';
    }
    if (value.processorCount < 1 ||
        value.processorCount > capabilities.maximumProcessors ||
        value.processorCount != value.processorArray.length) {
      return 'RSS processor count is invalid.';
    }
    if (!capabilities.processors.contains(value.baseProcessor) ||
        !capabilities.processors.contains(value.maximumProcessor) ||
        value.processorArray.any(
          (processor) => !capabilities.processors.contains(processor),
        )) {
      return 'RSS references a processor outside the live topology.';
    }
    if (value.baseProcessor.group != value.maximumProcessor.group) {
      return 'RSS range crosses processor groups.';
    }
    if (capabilities.nicNumaNode != null &&
        value.profile == 'Closest' &&
        value.processorArray.any(
          (processor) => processor.numaNode != capabilities.nicNumaNode,
        )) {
      return 'RSS Closest profile includes a remote NUMA processor.';
    }
    return null;
  }

  static String? validateMsiMessageCount({
    required bool msiSupported,
    required int requested,
    required int hardwareMaximum,
  }) {
    if (!msiSupported) return 'The device does not declare MSI/MSI-X support.';
    if (requested < 1 || requested > hardwareMaximum) {
      return 'MessageNumberLimit is outside the device limit.';
    }
    return null;
  }

  static String? validateAffinity({
    required int processorGroup,
    required BigInt mask,
    required Map<int, int> logicalProcessorsPerGroup,
  }) {
    final processorCount = logicalProcessorsPerGroup[processorGroup];
    if (processorCount == null) return 'Unknown processor group.';
    if (mask <= BigInt.zero) return 'Affinity mask must select a processor.';
    if ((mask >> processorCount) != BigInt.zero) {
      return 'Affinity mask cannot be represented without truncation.';
    }
    return null;
  }
}
