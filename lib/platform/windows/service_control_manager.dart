import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

typedef _ChangeServiceConfigNative =
    Int32 Function(
      IntPtr,
      Uint32,
      Uint32,
      Uint32,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Uint32>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
    );
typedef _ChangeServiceConfigDart =
    int Function(
      int,
      int,
      int,
      int,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Uint32>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
      Pointer<Utf16>,
    );

final _ChangeServiceConfigDart _changeServiceConfig =
    DynamicLibrary.open(
      'advapi32.dll',
    ).lookupFunction<_ChangeServiceConfigNative, _ChangeServiceConfigDart>(
      'ChangeServiceConfigW',
    );

class WindowsServiceInfo {
  const WindowsServiceInfo({
    required this.name,
    required this.displayName,
    required this.startType,
    required this.delayedAutoStart,
    required this.state,
    required this.account,
    required this.dependencies,
    required this.processId,
  });

  final String name;
  final String displayName;
  final int startType;
  final bool delayedAutoStart;
  final int state;
  final String account;
  final List<String> dependencies;
  final int processId;
}

abstract interface class ServiceConfigurationStore {
  WindowsServiceInfo inspect(String name);
  void configureStart(
    String name, {
    required int startType,
    required bool delayedAutoStart,
  });
}

class ServiceControlManager implements ServiceConfigurationStore {
  const ServiceControlManager();

  static const int _serviceQueryConfig = 1;
  static const int _serviceChangeConfig = 2;
  static const int _serviceNoChange = 0xffffffff;

  @override
  WindowsServiceInfo inspect(String name) {
    if (!RegExp(r'^[A-Za-z0-9_.-]{1,256}$').hasMatch(name)) {
      throw ArgumentError.value(name, 'name', 'Invalid service name.');
    }
    final manager = OpenSCManager(nullptr, nullptr, SC_MANAGER_CONNECT);
    if (manager == 0) _throwLastError('OpenSCManager');
    final namePointer = name.toNativeUtf16();
    try {
      final service = OpenService(
        manager,
        namePointer,
        _serviceQueryConfig | SERVICE_QUERY_STATUS,
      );
      if (service == 0) _throwLastError('OpenService $name');
      try {
        final config = _queryConfig(service);
        final status = calloc<SERVICE_STATUS_PROCESS>();
        final needed = calloc<Uint32>();
        try {
          if (QueryServiceStatusEx(
                service,
                SC_STATUS_PROCESS_INFO,
                status.cast<Uint8>(),
                sizeOf<SERVICE_STATUS_PROCESS>(),
                needed,
              ) ==
              FALSE) {
            _throwLastError('QueryServiceStatusEx $name');
          }
          return WindowsServiceInfo(
            name: name,
            displayName: _string(config.ref.lpDisplayName),
            startType: config.ref.dwStartType,
            delayedAutoStart: _queryDelayedAutoStart(service),
            state: status.ref.dwCurrentState,
            account: _string(config.ref.lpServiceStartName),
            dependencies: _multiString(config.ref.lpDependencies),
            processId: status.ref.dwProcessId,
          );
        } finally {
          calloc.free(config.cast<Uint8>());
          calloc.free(status);
          calloc.free(needed);
        }
      } finally {
        CloseServiceHandle(service);
      }
    } finally {
      calloc.free(namePointer);
      CloseServiceHandle(manager);
    }
  }

  @override
  void configureStart(
    String name, {
    required int startType,
    required bool delayedAutoStart,
  }) {
    if (!RegExp(r'^[A-Za-z0-9_.-]{1,256}$').hasMatch(name) ||
        !const <int>{
          SERVICE_AUTO_START,
          SERVICE_DEMAND_START,
          SERVICE_DISABLED,
        }.contains(startType)) {
      throw ArgumentError('Invalid service startup configuration.');
    }
    final manager = OpenSCManager(nullptr, nullptr, SC_MANAGER_CONNECT);
    if (manager == 0) _throwLastError('OpenSCManager');
    final pointer = name.toNativeUtf16();
    try {
      final service = OpenService(manager, pointer, _serviceChangeConfig);
      if (service == 0) _throwLastError('OpenService $name');
      try {
        if (_changeServiceConfig(
              service,
              _serviceNoChange,
              startType,
              _serviceNoChange,
              nullptr,
              nullptr,
              nullptr,
              nullptr,
              nullptr,
              nullptr,
              nullptr,
            ) ==
            FALSE) {
          _throwLastError('ChangeServiceConfig $name');
        }
        final delayed = calloc<SERVICE_DELAYED_AUTO_START_INFO>()
          ..ref.fDelayedAutostart = delayedAutoStart ? TRUE : FALSE;
        try {
          if (ChangeServiceConfig2(
                service,
                SERVICE_CONFIG_DELAYED_AUTO_START_INFO,
                delayed.cast(),
              ) ==
              FALSE) {
            _throwLastError('ChangeServiceConfig2 $name');
          }
        } finally {
          calloc.free(delayed);
        }
      } finally {
        CloseServiceHandle(service);
      }
    } finally {
      calloc.free(pointer);
      CloseServiceHandle(manager);
    }
  }

  static Pointer<QUERY_SERVICE_CONFIG> _queryConfig(int service) {
    final needed = calloc<Uint32>();
    try {
      QueryServiceConfig(service, nullptr, 0, needed);
      if (needed.value == 0) {
        _throwLastError('QueryServiceConfig size');
      }
      final buffer = calloc<Uint8>(needed.value);
      if (QueryServiceConfig(
            service,
            buffer.cast<QUERY_SERVICE_CONFIG>(),
            needed.value,
            needed,
          ) ==
          FALSE) {
        final result = GetLastError();
        calloc.free(buffer);
        throw WindowsException(
          HRESULT_FROM_WIN32(result),
          message: 'QueryServiceConfig',
        );
      }
      return buffer.cast<QUERY_SERVICE_CONFIG>();
    } finally {
      calloc.free(needed);
    }
  }

  static bool _queryDelayedAutoStart(int service) {
    final info = calloc<SERVICE_DELAYED_AUTO_START_INFO>();
    final needed = calloc<Uint32>();
    try {
      if (QueryServiceConfig2(
            service,
            SERVICE_CONFIG_DELAYED_AUTO_START_INFO,
            info.cast<Uint8>(),
            sizeOf<SERVICE_DELAYED_AUTO_START_INFO>(),
            needed,
          ) ==
          FALSE) {
        final error = GetLastError();
        if (error == ERROR_INVALID_LEVEL) return false;
        throw WindowsException(
          HRESULT_FROM_WIN32(error),
          message: 'QueryServiceConfig2',
        );
      }
      return info.ref.fDelayedAutostart != FALSE;
    } finally {
      calloc.free(info);
      calloc.free(needed);
    }
  }

  static String _string(Pointer<Utf16> value) =>
      value == nullptr ? '' : value.toDartString();

  static List<String> _multiString(Pointer<Utf16> value) {
    if (value == nullptr) return const <String>[];
    final result = <String>[];
    var offset = 0;
    while ((value.cast<Uint16>() + offset).value != 0) {
      final entry = (value.cast<Uint16>() + offset)
          .cast<Utf16>()
          .toDartString();
      result.add(entry);
      offset += entry.length + 1;
    }
    return result;
  }

  static Never _throwLastError(String operation) {
    throw WindowsException(
      HRESULT_FROM_WIN32(GetLastError()),
      message: operation,
    );
  }
}
