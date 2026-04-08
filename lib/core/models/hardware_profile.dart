class HardwareProfile {
  const HardwareProfile({
    required this.cpuName,
    required this.cpuVendor,
    required this.gpuNames,
    required this.gpuVendors,
    required this.ramInstalledBytes,
    required this.networkAdapters,
    required this.audioDevices,
  });

  final String cpuName;
  final String cpuVendor;
  final List<String> gpuNames;
  final Set<String> gpuVendors;
  final int ramInstalledBytes;
  final List<String> networkAdapters;
  final List<String> audioDevices;

  static const HardwareProfile unknown = HardwareProfile(
    cpuName: 'Unknown CPU',
    cpuVendor: 'unknown',
    gpuNames: <String>[],
    gpuVendors: <String>{},
    ramInstalledBytes: 0,
    networkAdapters: <String>[],
    audioDevices: <String>[],
  );

  double get ramInstalledGb => ramInstalledBytes / (1024 * 1024 * 1024);

  String get ramInstalledLabel {
    if (ramInstalledBytes <= 0) {
      return 'Unknown';
    }

    return '${ramInstalledGb.toStringAsFixed(1)} GB';
  }

  bool supportsCpu(String? vendor) {
    if (vendor == null) {
      return true;
    }
    return cpuVendor == vendor;
  }

  bool supportsAnyGpu(Set<String> vendors) {
    if (vendors.isEmpty) {
      return true;
    }
    return vendors.any(gpuVendors.contains);
  }

  bool get hasNetworkAdapters => networkAdapters.isNotEmpty;
  bool get hasAudioDevices => audioDevices.isNotEmpty;
}
