import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../domain/device_identity.dart';

final class _DevPropKey extends Struct {
  external GUID fmtid;

  @Uint32()
  external int pid;
}

typedef _GetDevicePropertyNative =
    Int32 Function(
      IntPtr,
      Pointer<SP_DEVINFO_DATA>,
      Pointer<_DevPropKey>,
      Pointer<Uint32>,
      Pointer<Uint8>,
      Uint32,
      Pointer<Uint32>,
      Uint32,
    );
typedef _GetDevicePropertyDart =
    int Function(
      int,
      Pointer<SP_DEVINFO_DATA>,
      Pointer<_DevPropKey>,
      Pointer<Uint32>,
      Pointer<Uint8>,
      int,
      Pointer<Uint32>,
      int,
    );

class SetupApiDeviceInventoryService {
  const SetupApiDeviceInventoryService();

  static final _GetDevicePropertyDart _getDeviceProperty =
      DynamicLibrary.open(
        'setupapi.dll',
      ).lookupFunction<_GetDevicePropertyNative, _GetDevicePropertyDart>(
        'SetupDiGetDevicePropertyW',
      );

  List<DeviceIdentity> scanPresent() {
    final devices = SetupDiGetClassDevs(
      nullptr,
      nullptr,
      0,
      DIGCF_ALLCLASSES | DIGCF_PRESENT,
    );
    if (devices == INVALID_HANDLE_VALUE) {
      throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
    }
    try {
      final result = <DeviceIdentity>[];
      for (var index = 0; ; index++) {
        final data = calloc<SP_DEVINFO_DATA>()
          ..ref.cbSize = sizeOf<SP_DEVINFO_DATA>();
        try {
          if (SetupDiEnumDeviceInfo(devices, index, data) == 0) {
            final error = GetLastError();
            if (error == ERROR_NO_MORE_ITEMS || (error == 0 && index > 0)) {
              break;
            }
            throw WindowsException(HRESULT_FROM_WIN32(error));
          }
          result.add(
            DeviceIdentity(
              instanceId: _instanceId(devices, data),
              classGuid: data.ref.ClassGuid.toString().toLowerCase(),
              description:
                  _stringProperty(devices, data, SPDRP_DEVICEDESC) ??
                  'Unknown device',
              hardwareIds: _multiStringProperty(
                devices,
                data,
                SPDRP_HARDWAREID,
              ),
              driverKey: _stringProperty(devices, data, SPDRP_DRIVER),
              driverInf: _driverInf(devices, data),
            ),
          );
        } finally {
          calloc.free(data);
        }
      }
      return result;
    } finally {
      SetupDiDestroyDeviceInfoList(devices);
    }
  }

  List<PciInterruptCapability> scanPciInterruptCapabilities() {
    final devices = SetupDiGetClassDevs(
      nullptr,
      nullptr,
      0,
      DIGCF_ALLCLASSES | DIGCF_PRESENT,
    );
    if (devices == INVALID_HANDLE_VALUE) {
      throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
    }
    try {
      final result = <PciInterruptCapability>[];
      final workingAudio = _controllersWithWorkingAudio();
      for (var index = 0; ; index++) {
        final data = calloc<SP_DEVINFO_DATA>()
          ..ref.cbSize = sizeOf<SP_DEVINFO_DATA>();
        try {
          if (SetupDiEnumDeviceInfo(devices, index, data) == 0) {
            final error = GetLastError();
            if (error == ERROR_NO_MORE_ITEMS || (error == 0 && index > 0)) {
              break;
            }
            throw WindowsException(HRESULT_FROM_WIN32(error));
          }
          final support = _pciProperty(devices, data, 14);
          final maximum = _pciProperty(devices, data, 15);
          if (support == null || maximum == null) continue;
          final device = DeviceIdentity(
            instanceId: _instanceId(devices, data),
            classGuid: data.ref.ClassGuid.toString().toLowerCase(),
            description:
                _stringProperty(devices, data, SPDRP_DEVICEDESC) ??
                'Unknown PCI device',
            hardwareIds: _multiStringProperty(devices, data, SPDRP_HARDWAREID),
            driverKey: _stringProperty(devices, data, SPDRP_DRIVER),
            driverInf: _driverInf(devices, data),
          );
          result.add(
            PciInterruptCapability(
              device: device,
              lineBased: support & 1 != 0,
              msi: support & 2 != 0,
              msiX: support & 4 != 0,
              messageMaximum: maximum,
              busNumber: _registryUint32(devices, data, SPDRP_BUSNUMBER),
              address: _registryUint32(devices, data, SPDRP_ADDRESS),
              audioInUse:
                  !device.hardwareIds.any((id) => id.contains('&CC_0403')) ||
                  workingAudio.contains(device.instanceId.toUpperCase()),
            ),
          );
        } finally {
          calloc.free(data);
        }
      }
      return result;
    } finally {
      SetupDiDestroyDeviceInfoList(devices);
    }
  }

  static int? _pciProperty(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    int propertyId,
  ) => _uint32Property(
    devices,
    data,
    '{3AB22E31-8264-4B4E-9AF5-A8D2D8E33E62}',
    propertyId,
  );

  // DEVPKEY_Device_* properties.
  static const _deviceKeys = '{4340A6C5-93FA-4706-972C-7B648008A5A7}';

  /// Upper-case instance IDs of the controllers that have at least one
  /// working HD Audio function (not disabled, no problem code).
  static Set<String> _controllersWithWorkingAudio() {
    final enumerator = 'HDAUDIO'.toNativeUtf16();
    final devices = SetupDiGetClassDevs(
      nullptr,
      enumerator,
      0,
      DIGCF_ALLCLASSES | DIGCF_PRESENT,
    );
    calloc.free(enumerator);
    if (devices == INVALID_HANDLE_VALUE) return const <String>{};
    final result = <String>{};
    try {
      for (var index = 0; ; index++) {
        final data = calloc<SP_DEVINFO_DATA>()
          ..ref.cbSize = sizeOf<SP_DEVINFO_DATA>();
        try {
          if (SetupDiEnumDeviceInfo(devices, index, data) == 0) break;
          final problem = _uint32Property(devices, data, _deviceKeys, 3);
          final parent = _stringDeviceProperty(devices, data, _deviceKeys, 8);
          if ((problem ?? 0) == 0 && parent != null) {
            result.add(parent.toUpperCase());
          }
        } finally {
          calloc.free(data);
        }
      }
    } finally {
      SetupDiDestroyDeviceInfoList(devices);
    }
    return result;
  }

  static Uint8List? _deviceProperty(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    String fmtid,
    int propertyId,
  ) => using((arena) {
    final key = arena<_DevPropKey>()
      ..ref.fmtid = GUIDFromString(fmtid, allocator: arena).ref
      ..ref.pid = propertyId;
    final type = arena<Uint32>();
    final required = arena<Uint32>();
    _getDeviceProperty(devices, data, key, type, nullptr, 0, required, 0);
    if (required.value == 0) return null;
    final buffer = arena<Uint8>(required.value);
    final success = _getDeviceProperty(
      devices,
      data,
      key,
      type,
      buffer,
      required.value,
      required,
      0,
    );
    return success == 0
        ? null
        : Uint8List.fromList(buffer.asTypedList(required.value));
  });

  static int? _uint32Property(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    String fmtid,
    int propertyId,
  ) {
    final bytes = _deviceProperty(devices, data, fmtid, propertyId);
    return bytes == null || bytes.length != 4
        ? null
        : ByteData.sublistView(bytes).getUint32(0, Endian.little);
  }

  static String? _stringDeviceProperty(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    String fmtid,
    int propertyId,
  ) {
    final bytes = _deviceProperty(devices, data, fmtid, propertyId);
    if (bytes == null || bytes.length < 2) return null;
    final units = bytes.buffer.asUint16List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 2,
    );
    final end = units.indexOf(0);
    return String.fromCharCodes(end < 0 ? units : units.sublist(0, end));
  }

  static int? _registryUint32(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    int property,
  ) {
    final bytes = _property(devices, data, property);
    return bytes == null || bytes.length != 4
        ? null
        : ByteData.sublistView(bytes).getUint32(0, Endian.little);
  }

  static String? _driverInf(int devices, Pointer<SP_DEVINFO_DATA> data) {
    final key = SetupDiOpenDevRegKey(
      devices,
      data,
      DICS_FLAG_GLOBAL,
      0,
      DIREG_DRV,
      KEY_READ,
    );
    if (key == INVALID_HANDLE_VALUE) return null;
    final name = 'InfPath'.toNativeUtf16();
    final type = calloc<Uint32>();
    final size = calloc<Uint32>();
    try {
      RegQueryValueEx(key, name, nullptr, type, nullptr, size);
      if (size.value == 0 || type.value != REG_SZ) return null;
      final buffer = calloc<Uint8>(size.value);
      try {
        final result = RegQueryValueEx(key, name, nullptr, type, buffer, size);
        if (result != ERROR_SUCCESS) return null;
        return buffer.cast<Utf16>().toDartString().toLowerCase();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      RegCloseKey(key);
      calloc.free(name);
      calloc.free(type);
      calloc.free(size);
    }
  }

  static String _instanceId(int devices, Pointer<SP_DEVINFO_DATA> data) {
    final required = calloc<Uint32>();
    try {
      SetupDiGetDeviceInstanceId(devices, data, nullptr, 0, required);
      if (required.value == 0) {
        throw WindowsException(
          HRESULT_FROM_WIN32(GetLastError()),
          message: 'SetupDiGetDeviceInstanceId size',
        );
      }
      final buffer = calloc<Uint16>(required.value);
      try {
        if (SetupDiGetDeviceInstanceId(
              devices,
              data,
              buffer.cast<Utf16>(),
              required.value,
              required,
            ) ==
            0) {
          throw WindowsException(
            HRESULT_FROM_WIN32(GetLastError()),
            message: 'SetupDiGetDeviceInstanceId',
          );
        }
        return buffer.cast<Utf16>().toDartString().toUpperCase();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(required);
    }
  }

  static String? _stringProperty(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    int property,
  ) {
    final bytes = _property(devices, data, property);
    if (bytes == null || bytes.isEmpty) return null;
    final units = bytes.buffer.asUint16List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 2,
    );
    final end = units.indexOf(0);
    return String.fromCharCodes(end < 0 ? units : units.sublist(0, end));
  }

  static Set<String> _multiStringProperty(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    int property,
  ) {
    final bytes = _property(devices, data, property);
    if (bytes == null || bytes.isEmpty) return const <String>{};
    final units = bytes.buffer.asUint16List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 2,
    );
    final result = <String>{};
    var start = 0;
    for (var index = 0; index < units.length; index++) {
      if (units[index] != 0) continue;
      if (index == start) break;
      result.add(
        String.fromCharCodes(units.sublist(start, index)).toUpperCase(),
      );
      start = index + 1;
    }
    return result;
  }

  static Uint8List? _property(
    int devices,
    Pointer<SP_DEVINFO_DATA> data,
    int property,
  ) {
    final type = calloc<Uint32>();
    final required = calloc<Uint32>();
    try {
      SetupDiGetDeviceRegistryProperty(
        devices,
        data,
        property,
        type,
        nullptr,
        0,
        required,
      );
      if (required.value == 0) return null;
      final buffer = calloc<Uint8>(required.value);
      try {
        if (SetupDiGetDeviceRegistryProperty(
              devices,
              data,
              property,
              type,
              buffer,
              required.value,
              required,
            ) ==
            0) {
          return null;
        }
        return Uint8List.fromList(buffer.asTypedList(required.value));
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(type);
      calloc.free(required);
    }
  }
}
