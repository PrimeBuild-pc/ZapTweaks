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
