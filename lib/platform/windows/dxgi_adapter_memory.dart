import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// DXGI_ADAPTER_DESC1 uses SIZE_T for memory sizes (not WMI's 32-bit AdapterRAM).
final class _AdapterDescription extends Struct {
  @Array(128)
  external Array<Uint16> description;
  @Uint32()
  external int vendorId;
  @Uint32()
  external int deviceId;
  @Uint32()
  external int subSysId;
  @Uint32()
  external int revision;
  @UintPtr()
  external int dedicatedVideoMemory;
  @UintPtr()
  external int dedicatedSystemMemory;
  @UintPtr()
  external int sharedSystemMemory;
  external LUID luid;
  @Uint32()
  external int flags;
}

typedef _CreateNative = Int32 Function(Pointer<GUID>, Pointer<Pointer<Void>>);
typedef _CreateDart = int Function(Pointer<GUID>, Pointer<Pointer<Void>>);
typedef _EnumerateNative =
    Int32 Function(Pointer<Void>, Uint32, Pointer<Pointer<Void>>);
typedef _EnumerateDart =
    int Function(Pointer<Void>, int, Pointer<Pointer<Void>>);
typedef _DescribeNative =
    Int32 Function(Pointer<Void>, Pointer<_AdapterDescription>);
typedef _DescribeDart =
    int Function(Pointer<Void>, Pointer<_AdapterDescription>);
typedef _ReleaseNative = Uint32 Function(Pointer<Void>);
typedef _ReleaseDart = int Function(Pointer<Void>);

/// Read-only IDXGIFactory1/IDXGIAdapter1 enumeration, keyed exactly like PDH.
/// Unknown or linked physical nodes remain unavailable rather than borrowing
/// another adapter's memory size. No hardware, driver or registry writes.
Map<String, ({String name, int bytes})> readDxgiAdapterMemory() {
  if (!Platform.isWindows) return const {};
  final iid = calloc<GUID>()
    ..ref.setGUID('{770aae78-f26f-4dba-a829-253c83d1b387}');
  final factory = calloc<Pointer<Void>>();
  final adapter = calloc<Pointer<Void>>();
  final description = calloc<_AdapterDescription>();
  Pointer<Void> method(Pointer<Void> object, int index) =>
      object.cast<Pointer<Pointer<Void>>>().value[index];
  void release(Pointer<Void> object) {
    if (object != nullptr) {
      method(object, 2)
          .cast<NativeFunction<_ReleaseNative>>()
          .asFunction<_ReleaseDart>()(object);
    }
  }

  try {
    final create = DynamicLibrary.open(
      'dxgi.dll',
    ).lookupFunction<_CreateNative, _CreateDart>('CreateDXGIFactory1');
    if (create(iid, factory) < 0 || factory.value == nullptr) return const {};
    final enumerate = method(
      factory.value,
      12,
    ).cast<NativeFunction<_EnumerateNative>>().asFunction<_EnumerateDart>();
    final result = <String, ({String name, int bytes})>{};
    for (var index = 0; index < 32; index++) {
      adapter.value = nullptr;
      if (enumerate(factory.value, index, adapter) < 0 ||
          adapter.value == nullptr) {
        break;
      }
      try {
        final describe = method(
          adapter.value,
          10,
        ).cast<NativeFunction<_DescribeNative>>().asFunction<_DescribeDart>();
        if (describe(adapter.value, description) < 0) continue;
        final data = description.ref;
        if ((data.flags & 2) != 0 || data.dedicatedVideoMemory <= 0) continue;
        String hex(int value) =>
            value.toUnsigned(32).toRadixString(16).padLeft(8, '0');
        final id =
            'luid_0x${hex(data.luid.HighPart)}_0x${hex(data.luid.LowPart)}_phys_0';
        final chars = <int>[];
        for (var i = 0; i < 128 && data.description[i] != 0; i++) {
          chars.add(data.description[i]);
        }
        result[id] = (
          name: String.fromCharCodes(chars),
          bytes: data.dedicatedVideoMemory,
        );
      } finally {
        release(adapter.value);
        adapter.value = nullptr;
      }
    }
    return result;
  } catch (_) {
    return const {};
  } finally {
    release(factory.value);
    calloc.free(iid);
    calloc.free(factory);
    calloc.free(adapter);
    calloc.free(description);
  }
}
