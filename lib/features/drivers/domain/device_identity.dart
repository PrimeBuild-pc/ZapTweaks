class PciInterruptCapability {
  const PciInterruptCapability({
    required this.device,
    required this.lineBased,
    required this.msi,
    required this.msiX,
    required this.messageMaximum,
  });

  final DeviceIdentity device;
  final bool lineBased;
  final bool msi;
  final bool msiX;
  final int messageMaximum;
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
