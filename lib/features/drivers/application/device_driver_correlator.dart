import '../domain/device_driver_binding.dart';
import '../domain/device_identity.dart';
import '../domain/driver_package.dart';

class DeviceDriverCorrelator {
  const DeviceDriverCorrelator();

  List<DeviceDriverBinding> correlate(
    Iterable<DeviceIdentity> devices,
    Iterable<DriverPackage> packages,
  ) {
    final packageList = packages.toList(growable: false);
    final byPublishedName = <String, DriverPackage>{
      for (final package in packageList)
        package.publishedName.toLowerCase(): package,
    };
    return devices
        .map((device) {
          final inf = device.driverInf?.toLowerCase();
          final bound = inf == null ? null : byPublishedName[inf];
          if (bound != null) {
            return DeviceDriverBinding(
              device: device,
              package: bound,
              match: DriverBindingMatch.boundInf,
            );
          }
          final hardwareIds = device.hardwareIds
              .map((id) => id.toUpperCase())
              .toSet();
          final candidates = packageList
              .where((package) => package.supportsAny(hardwareIds))
              .toList(growable: false);
          return DeviceDriverBinding(
            device: device,
            package: candidates.length == 1 ? candidates.single : null,
            match: candidates.length == 1
                ? DriverBindingMatch.hardwareId
                : DriverBindingMatch.none,
          );
        })
        .toList(growable: false);
  }
}
