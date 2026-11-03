class PciInterruptCapability {
  const PciInterruptCapability({
    required this.device,
    required this.lineBased,
    required this.msi,
    required this.msiX,
    required this.messageMaximum,
    this.busNumber,
    this.address,
    this.audioInUse = true,
  });

  final DeviceIdentity device;
  final bool lineBased;
  final bool msi;
  final bool msiX;
  final int messageMaximum;

  /// PCI bus, and `device << 16 | function` on that bus.
  final int? busNumber;
  final int? address;

  /// For HD Audio controllers: false when no audio function behind it works
  /// (all disabled or missing).
  final bool audioInUse;
}

class DeviceIdentity {
  const DeviceIdentity({
    required this.instanceId,
    required this.classGuid,
    required this.description,
    required this.hardwareIds,
    required this.driverKey,
    required this.driverInf,
  });

  final String instanceId;
  final String classGuid;
  final String description;
  final Set<String> hardwareIds;
  final String? driverKey;
  final String? driverInf;
}
