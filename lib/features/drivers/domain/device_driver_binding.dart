import 'device_identity.dart';
import 'driver_package.dart';

enum DriverBindingMatch { boundInf, hardwareId, none }

class DeviceDriverBinding {
  const DeviceDriverBinding({
    required this.device,
    required this.package,
    required this.match,
  });

  final DeviceIdentity device;
  final DriverPackage? package;
  final DriverBindingMatch match;

  bool get verified => package != null && match != DriverBindingMatch.none;
}
