import 'dart:typed_data';

import 'package:win32/win32.dart';

import '../platform/windows/registry_value_store.dart';
import 'services/process_runner.dart';

class RegistryException implements Exception {
  RegistryException(this.message, {this.exitCode});

  final String message;
  final int? exitCode;

  @override
  String toString() => message;
}

class RegistryManager {
  static const RegistryValueStore _store = WindowsRegistryValueStore();

  static Future<int?> readDword(String keyPath, String valueName) async {
    try {
      final value = await _store.read(keyPath, valueName);
      if (value == null || value.type != REG_DWORD || value.bytes.length < 4) {
        return null;
      }
      return ByteData.sublistView(value.bytes).getUint32(0, Endian.little);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> readString(String keyPath, String valueName) async {
    try {
      final value = await _store.read(keyPath, valueName);
      if (value == null ||
          (value.type != REG_SZ && value.type != REG_EXPAND_SZ)) {
        return null;
      }
      final length = value.bytes.length - (value.bytes.length % 2);
      final data = ByteData.sublistView(value.bytes, 0, length);
      final units = <int>[
        for (var offset = 0; offset < length; offset += 2)
          data.getUint16(offset, Endian.little),
      ];
      while (units.isNotEmpty && units.last == 0) {
        units.removeLast();
      }
      final result = String.fromCharCodes(units).trim();
      return result.isEmpty ? null : result;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeDword(String keyPath, String valueName, int value) =>
      _write(
        keyPath,
        valueName,
        RawRegistryValue(
          type: REG_DWORD,
          bytes: Uint8List(4)
            ..buffer.asByteData().setUint32(
              0,
              value.toUnsigned(32),
              Endian.little,
            ),
        ),
      );

  static Future<void> writeString(
    String keyPath,
    String valueName,
    String value,
  ) {
    final units = '$value\u0000'.codeUnits;
    final bytes = Uint8List(units.length * 2);
    final data = bytes.buffer.asByteData();
    for (var index = 0; index < units.length; index++) {
      data.setUint16(index * 2, units[index], Endian.little);
    }
    return _write(
      keyPath,
      valueName,
      RawRegistryValue(type: REG_SZ, bytes: bytes),
    );
  }

  static Future<void> writeBinary(
    String keyPath,
    String valueName,
    String hexValue,
  ) {
    final normalized = hexValue.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (normalized.length.isOdd || normalized.length != hexValue.length) {
      throw RegistryException('Invalid REG_BINARY value.');
    }
    return _write(
      keyPath,
      valueName,
      RawRegistryValue(
        type: REG_BINARY,
        bytes: Uint8List.fromList(<int>[
          for (var index = 0; index < normalized.length; index += 2)
            int.parse(normalized.substring(index, index + 2), radix: 16),
        ]),
      ),
    );
  }

  static Future<void> deleteValue(String keyPath, String valueName) async {
    if (ProcessRunner.shared.isDryRun) return;
    try {
      await _store.delete(keyPath, valueName);
    } catch (error) {
      throw RegistryException(
        'Registry delete failed: $keyPath/$valueName | $error',
      );
    }
  }

  static Future<void> _write(
    String keyPath,
    String valueName,
    RawRegistryValue value,
  ) async {
    if (ProcessRunner.shared.isDryRun) return;
    try {
      await _store.write(keyPath, valueName, value);
    } catch (error) {
      throw RegistryException(
        'Registry write failed: $keyPath/$valueName | $error',
      );
    }
  }
}
