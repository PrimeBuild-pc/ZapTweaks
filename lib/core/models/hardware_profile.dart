class HardwareProfile {
  const HardwareProfile({
    required this.cpuName,
    required this.cpuVendor,
    required this.gpuNames,
    required this.gpuVendors,
    required this.ramInstalledBytes,
    required this.networkAdapters,
    required this.audioDevices,
    this.gpuDrivers = const <String>[],
    this.chipsetDrivers = const <String>[],
    this.monitors = const <String>[],
    this.mice = const <String>[],
    this.keyboards = const <String>[],
    this.windowsBuild = 0,
  });

  final String cpuName;
  final String cpuVendor;
  final List<String> gpuNames;
  final Set<String> gpuVendors;
  final int ramInstalledBytes;
  final List<String> networkAdapters;
  final List<String> audioDevices;
  final List<String> gpuDrivers;
  final List<String> chipsetDrivers;
  final List<String> monitors;
  final List<String> mice;
  final List<String> keyboards;
  final int windowsBuild;

  static const HardwareProfile unknown = HardwareProfile(
    cpuName: 'Unknown CPU',
    cpuVendor: 'unknown',
    gpuNames: <String>[],
    gpuVendors: <String>{},
    ramInstalledBytes: 0,
    networkAdapters: <String>[],
    audioDevices: <String>[],
    windowsBuild: 0,
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
}
