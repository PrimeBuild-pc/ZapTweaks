import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../domain/device_identity.dart';

class SetupApiDeviceInventoryService {
  const SetupApiDeviceInventoryService();

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
