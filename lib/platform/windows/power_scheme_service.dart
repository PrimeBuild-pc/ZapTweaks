import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class PowerSettingValue {
  const PowerSettingValue({required this.ac, required this.dc});

  final int ac;
  final int dc;
}

abstract interface class PowerSchemeStore {
  String get activeSchemeId;

  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  );

  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  );

  void setActiveScheme(String schemeId);
}

class PowerSettingInfo {
  const PowerSettingInfo({
    required this.subgroupId,
    required this.subgroupName,
    required this.settingId,
    required this.name,
    required this.description,
    required this.value,
    this.minimum,
    this.maximum,
    this.increment,
    this.units,
    this.possibleValues = const <int, String>{},
  });

  final String subgroupId;
  final String subgroupName;
  final String settingId;
  final String name;
  final String description;
  final PowerSettingValue value;
  final int? minimum;
  final int? maximum;
  final int? increment;
  final String? units;
  final Map<int, String> possibleValues;
}

abstract interface class PowerSchemeInventory {
  List<PowerSchemeInfo> enumerate();
}

abstract interface class PowerSchemeManagement implements PowerSchemeInventory {
  String duplicateScheme(String schemeId, String name);
  void renameScheme(String schemeId, String name);
  void deleteScheme(String schemeId);
}

abstract interface class PowerSchemeAdministration
    implements PowerSchemeManagement, PowerSchemeStore {
  List<PowerSettingInfo> enumerateSettings(String schemeId);
}

class PowerSchemeInfo {
  const PowerSchemeInfo({
    required this.id,
    required this.name,
    required this.active,
  });

  final String id;
  final String name;
  final bool active;
}

typedef _PowerGetActiveSchemeNative =
    Uint32 Function(IntPtr, Pointer<Pointer<GUID>>);
typedef _PowerGetActiveSchemeDart = int Function(int, Pointer<Pointer<GUID>>);
typedef _PowerEnumerateNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Uint32,
      Uint32,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerEnumerateDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      int,
      int,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadFriendlyNameNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadFriendlyNameDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadValueIndexNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint32>,
    );
typedef _PowerReadValueIndexDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint32>,
    );
typedef _PowerWriteValueIndexNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Uint32,
    );
typedef _PowerWriteValueIndexDart =
    int Function(int, Pointer<GUID>, Pointer<GUID>, Pointer<GUID>, int);
typedef _PowerReadValueBoundNative =
    Uint32 Function(IntPtr, Pointer<GUID>, Pointer<GUID>, Pointer<Uint32>);
typedef _PowerReadValueBoundDart =
    int Function(int, Pointer<GUID>, Pointer<GUID>, Pointer<Uint32>);
typedef _PowerReadUnitsNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadUnitsDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadPossibleValueNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint32>,
      Uint32,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadPossibleValueDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint32>,
      int,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadPossibleNameNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Uint32,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadPossibleNameDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      int,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerSetActiveSchemeNative = Uint32 Function(IntPtr, Pointer<GUID>);
typedef _PowerSetActiveSchemeDart = int Function(int, Pointer<GUID>);
typedef _PowerDuplicateSchemeNative =
    Uint32 Function(IntPtr, Pointer<GUID>, Pointer<Pointer<GUID>>);
typedef _PowerDuplicateSchemeDart =
    int Function(int, Pointer<GUID>, Pointer<Pointer<GUID>>);
typedef _PowerDeleteSchemeNative = Uint32 Function(IntPtr, Pointer<GUID>);
typedef _PowerDeleteSchemeDart = int Function(int, Pointer<GUID>);
typedef _PowerWriteFriendlyNameNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Uint32,
    );
typedef _PowerWriteFriendlyNameDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      int,
    );

class WindowsPowerSchemeService implements PowerSchemeAdministration {
  WindowsPowerSchemeService({DynamicLibrary? library})
    : _library = library ?? DynamicLibrary.open('powrprof.dll') {
    _getActiveScheme = _library
        .lookupFunction<_PowerGetActiveSchemeNative, _PowerGetActiveSchemeDart>(
          'PowerGetActiveScheme',
        );
    _enumerate = _library
        .lookupFunction<_PowerEnumerateNative, _PowerEnumerateDart>(
          'PowerEnumerate',
        );
    _readFriendlyName = _library
        .lookupFunction<
          _PowerReadFriendlyNameNative,
          _PowerReadFriendlyNameDart
        >('PowerReadFriendlyName');
    _readDescription = _library
        .lookupFunction<
          _PowerReadFriendlyNameNative,
          _PowerReadFriendlyNameDart
        >('PowerReadDescription');
    _readAcValueIndex = _library
        .lookupFunction<_PowerReadValueIndexNative, _PowerReadValueIndexDart>(
          'PowerReadACValueIndex',
        );
    _readDcValueIndex = _library
        .lookupFunction<_PowerReadValueIndexNative, _PowerReadValueIndexDart>(
          'PowerReadDCValueIndex',
        );
    _writeAcValueIndex = _library
        .lookupFunction<_PowerWriteValueIndexNative, _PowerWriteValueIndexDart>(
          'PowerWriteACValueIndex',
        );
    _writeDcValueIndex = _library
        .lookupFunction<_PowerWriteValueIndexNative, _PowerWriteValueIndexDart>(
          'PowerWriteDCValueIndex',
        );
    _readValueMin = _library
        .lookupFunction<_PowerReadValueBoundNative, _PowerReadValueBoundDart>(
          'PowerReadValueMin',
        );
    _readValueMax = _library
        .lookupFunction<_PowerReadValueBoundNative, _PowerReadValueBoundDart>(
          'PowerReadValueMax',
        );
    _readValueIncrement = _library
        .lookupFunction<_PowerReadValueBoundNative, _PowerReadValueBoundDart>(
          'PowerReadValueIncrement',
        );
    _readUnits = _library
        .lookupFunction<_PowerReadUnitsNative, _PowerReadUnitsDart>(
          'PowerReadValueUnitsSpecifier',
        );
    _readPossibleValue = _library
        .lookupFunction<
          _PowerReadPossibleValueNative,
          _PowerReadPossibleValueDart
        >('PowerReadPossibleValue');
    _readPossibleFriendlyName = _library
        .lookupFunction<
          _PowerReadPossibleNameNative,
          _PowerReadPossibleNameDart
        >('PowerReadPossibleFriendlyName');
    _setActiveScheme = _library
        .lookupFunction<_PowerSetActiveSchemeNative, _PowerSetActiveSchemeDart>(
          'PowerSetActiveScheme',
        );
    _duplicateScheme = _library
        .lookupFunction<_PowerDuplicateSchemeNative, _PowerDuplicateSchemeDart>(
          'PowerDuplicateScheme',
        );
    _deleteScheme = _library
        .lookupFunction<_PowerDeleteSchemeNative, _PowerDeleteSchemeDart>(
          'PowerDeleteScheme',
        );
    _writeFriendlyName = _library
        .lookupFunction<
          _PowerWriteFriendlyNameNative,
          _PowerWriteFriendlyNameDart
        >('PowerWriteFriendlyName');
  }

  static const int _accessScheme = 16;
  static const int _accessSubgroup = 17;
  static const int _accessIndividualSetting = 18;
  final DynamicLibrary _library;
  late final _PowerGetActiveSchemeDart _getActiveScheme;
  late final _PowerEnumerateDart _enumerate;
  late final _PowerReadFriendlyNameDart _readFriendlyName;
  late final _PowerReadFriendlyNameDart _readDescription;
  late final _PowerReadValueIndexDart _readAcValueIndex;
  late final _PowerReadValueIndexDart _readDcValueIndex;
  late final _PowerWriteValueIndexDart _writeAcValueIndex;
  late final _PowerWriteValueIndexDart _writeDcValueIndex;
  late final _PowerReadValueBoundDart _readValueMin;
  late final _PowerReadValueBoundDart _readValueMax;
  late final _PowerReadValueBoundDart _readValueIncrement;
  late final _PowerReadUnitsDart _readUnits;
  late final _PowerReadPossibleValueDart _readPossibleValue;
  late final _PowerReadPossibleNameDart _readPossibleFriendlyName;
  late final _PowerSetActiveSchemeDart _setActiveScheme;
  late final _PowerDuplicateSchemeDart _duplicateScheme;
  late final _PowerDeleteSchemeDart _deleteScheme;
  late final _PowerWriteFriendlyNameDart _writeFriendlyName;

  @override
  String get activeSchemeId => _activeSchemeId();

  @override
  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  ) => using((arena) {
    final scheme = _guid(schemeId, arena);
    final subgroup = _guid(subgroupId, arena);
    final setting = _guid(settingId, arena);
    final ac = arena<Uint32>();
    final dc = arena<Uint32>();
    _check(
      _readAcValueIndex(0, scheme, subgroup, setting, ac),
      'PowerReadACValueIndex',
    );
    _check(
      _readDcValueIndex(0, scheme, subgroup, setting, dc),
      'PowerReadDCValueIndex',
    );
    return PowerSettingValue(ac: ac.value, dc: dc.value);
  });

  @override
  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  ) => using((arena) {
    final scheme = _guid(schemeId, arena);
    final subgroup = _guid(subgroupId, arena);
    final setting = _guid(settingId, arena);
    _check(
      _writeAcValueIndex(0, scheme, subgroup, setting, value.ac),
      'PowerWriteACValueIndex',
    );
    _check(
      _writeDcValueIndex(0, scheme, subgroup, setting, value.dc),
      'PowerWriteDCValueIndex',
    );
  });

  @override
  void setActiveScheme(String schemeId) => using((arena) {
    _check(_setActiveScheme(0, _guid(schemeId, arena)), 'PowerSetActiveScheme');
  });

  @override
  String duplicateScheme(String schemeId, String name) => using((arena) {
    final duplicated = arena<Pointer<GUID>>();
    _check(
      _duplicateScheme(0, _guid(schemeId, arena), duplicated),
      'PowerDuplicateScheme',
    );
    try {
      final id = duplicated.value.ref.toString().toLowerCase();
      renameScheme(id, name);
      return id;
    } finally {
      LocalFree(duplicated.value.cast());
    }
  });

  @override
  void renameScheme(String schemeId, String name) => using((arena) {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.length > 128 ||
        trimmed.runes.any((rune) => rune < 32)) {
      throw ArgumentError('Invalid power scheme name.');
    }
    final value = trimmed.toNativeUtf16(allocator: arena);
    _check(
      _writeFriendlyName(
        0,
        _guid(schemeId, arena),
        nullptr,
        nullptr,
        value.cast<Uint8>(),
        (trimmed.codeUnits.length + 1) * sizeOf<Uint16>(),
      ),
      'PowerWriteFriendlyName',
    );
  });

  @override
  void deleteScheme(String schemeId) {
    if (schemeId.toLowerCase() == activeSchemeId) {
      throw StateError('The active power scheme cannot be deleted.');
    }
    using((arena) {
      _check(_deleteScheme(0, _guid(schemeId, arena)), 'PowerDeleteScheme');
    });
  }

  @override
  List<PowerSchemeInfo> enumerate() {
    final active = _activeSchemeId();
    final schemes = <PowerSchemeInfo>[];
    for (var index = 0; ; index++) {
      final guid = calloc<GUID>();
      final size = calloc<Uint32>()..value = sizeOf<GUID>();
      try {
        final result = _enumerate(
          0,
          nullptr,
          nullptr,
          _accessScheme,
          index,
          guid.cast<Uint8>(),
          size,
        );
        if (result == ERROR_NO_MORE_ITEMS) break;
        _check(result, 'PowerEnumerate');
        final id = guid.ref.toString().toLowerCase();
        schemes.add(
          PowerSchemeInfo(
            id: id,
            name: _friendlyName(guid),
            active: id == active,
          ),
        );
      } finally {
        calloc.free(guid);
        calloc.free(size);
      }
    }
    return schemes;
  }

  @override
  List<PowerSettingInfo> enumerateSettings(String schemeId) => using((arena) {
    final scheme = _guid(schemeId, arena);
    final settings = <PowerSettingInfo>[];
    for (final subgroupId in _enumerateIds(scheme, nullptr, _accessSubgroup)) {
      final subgroup = _guid(subgroupId, arena);
      final subgroupName = _readText(
        _readFriendlyName,
        scheme,
        subgroup,
        nullptr,
        optional: true,
      );
      for (final settingId in _enumerateIds(
        scheme,
        subgroup,
        _accessIndividualSetting,
      )) {
        final setting = _guid(settingId, arena);
        final settingName = _readText(
          _readFriendlyName,
          scheme,
          subgroup,
          setting,
          optional: true,
        );
        settings.add(
          PowerSettingInfo(
            subgroupId: subgroupId,
            subgroupName: subgroupName.isEmpty ? subgroupId : subgroupName,
            settingId: settingId,
            name: settingName.isEmpty ? settingId : settingName,
            description: _readText(
              _readDescription,
              scheme,
              subgroup,
              setting,
              optional: true,
            ),
            value: readSetting(schemeId, subgroupId, settingId),
            minimum: _readBound(_readValueMin, subgroup, setting),
            maximum: _readBound(_readValueMax, subgroup, setting),
            increment: _readBound(_readValueIncrement, subgroup, setting),
            units: _readUnitsText(subgroup, setting),
            possibleValues: _readPossibleValues(subgroup, setting),
          ),
        );
      }
    }
    return settings;
  });

  List<String> _enumerateIds(
    Pointer<GUID> scheme,
    Pointer<GUID> subgroup,
    int access,
  ) {
    final ids = <String>[];
    for (var index = 0; ; index++) {
      final guid = calloc<GUID>();
      final size = calloc<Uint32>()..value = sizeOf<GUID>();
      try {
        final result = _enumerate(
          0,
          scheme,
          subgroup,
          access,
          index,
          guid.cast<Uint8>(),
          size,
        );
        if (result == ERROR_NO_MORE_ITEMS) break;
        _check(result, 'PowerEnumerate');
        ids.add(guid.ref.toString().toLowerCase());
      } finally {
        calloc.free(guid);
        calloc.free(size);
      }
    }
    return ids;
  }

  int? _readBound(
    _PowerReadValueBoundDart reader,
    Pointer<GUID> subgroup,
    Pointer<GUID> setting,
  ) {
    final value = calloc<Uint32>();
    try {
      return reader(0, subgroup, setting, value) == ERROR_SUCCESS
          ? value.value
          : null;
    } finally {
      calloc.free(value);
    }
  }

  String? _readUnitsText(Pointer<GUID> subgroup, Pointer<GUID> setting) {
    final size = calloc<Uint32>();
    try {
      final first = _readUnits(0, subgroup, setting, nullptr, size);
      if (first != ERROR_MORE_DATA || size.value < 2) return null;
      final buffer = calloc<Uint8>(size.value);
      try {
        if (_readUnits(0, subgroup, setting, buffer, size) != ERROR_SUCCESS) {
          return null;
        }
        final value = buffer.cast<Utf16>().toDartString().trim();
        return value.isEmpty ? null : value;
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(size);
    }
  }

  Map<int, String> _readPossibleValues(
    Pointer<GUID> subgroup,
    Pointer<GUID> setting,
  ) {
    final result = <int, String>{};
    for (var index = 0; index < 256; index++) {
      final type = calloc<Uint32>();
      final size = calloc<Uint32>();
      try {
        final first = _readPossibleValue(
          0,
          subgroup,
          setting,
          type,
          index,
          nullptr,
          size,
        );
        if ((first != ERROR_MORE_DATA && first != ERROR_SUCCESS) ||
            size.value != 4) {
          break;
        }
        final buffer = calloc<Uint8>(size.value);
        try {
          if (_readPossibleValue(
                0,
                subgroup,
                setting,
                type,
                index,
                buffer,
                size,
              ) !=
              ERROR_SUCCESS) {
            break;
          }
          final value = ByteData.sublistView(
            Uint8List.fromList(buffer.asTypedList(4)),
          ).getUint32(0, Endian.little);
          result[value] = _possibleName(subgroup, setting, index) ?? '$value';
        } finally {
          calloc.free(buffer);
        }
      } finally {
        calloc.free(type);
        calloc.free(size);
      }
    }
    return Map.unmodifiable(result);
  }

  String? _possibleName(
    Pointer<GUID> subgroup,
    Pointer<GUID> setting,
    int index,
  ) {
    final size = calloc<Uint32>();
    try {
      final first = _readPossibleFriendlyName(
        0,
        subgroup,
        setting,
        index,
        nullptr,
        size,
      );
      if ((first != ERROR_MORE_DATA && first != ERROR_SUCCESS) ||
          size.value < 2) {
        return null;
      }
      final buffer = calloc<Uint8>(size.value);
      try {
        if (_readPossibleFriendlyName(
              0,
              subgroup,
              setting,
              index,
              buffer,
              size,
            ) !=
            ERROR_SUCCESS) {
          return null;
        }
        final value = buffer.cast<Utf16>().toDartString().trim();
        return value.isEmpty ? null : value;
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(size);
    }
  }

  String _activeSchemeId() {
    final pointer = calloc<Pointer<GUID>>();
    try {
      _check(_getActiveScheme(0, pointer), 'PowerGetActiveScheme');
      try {
        return pointer.value.ref.toString().toLowerCase();
      } finally {
        LocalFree(pointer.value.cast());
      }
    } finally {
      calloc.free(pointer);
    }
  }

  String _friendlyName(Pointer<GUID> scheme) =>
      _readText(_readFriendlyName, scheme, nullptr, nullptr);

  String _readText(
    _PowerReadFriendlyNameDart reader,
    Pointer<GUID> scheme,
    Pointer<GUID> subgroup,
    Pointer<GUID> setting, {
    bool optional = false,
  }) {
    final size = calloc<Uint32>();
    try {
      final first = reader(0, scheme, subgroup, setting, nullptr, size);
      if (optional && first == ERROR_FILE_NOT_FOUND) return '';
      if (first != ERROR_MORE_DATA) _check(first, 'PowrProf text size');
      final buffer = calloc<Uint8>(size.value);
      try {
        _check(
          reader(0, scheme, subgroup, setting, buffer, size),
          'PowrProf text',
        );
        return buffer.cast<Utf16>().toDartString();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(size);
    }
  }

  static Pointer<GUID> _guid(String value, Allocator allocator) =>
      GUIDFromString(
        value.startsWith('{') ? value : '{$value}',
        allocator: allocator,
      );

  static void _check(int result, String operation) {
    if (result != ERROR_SUCCESS) {
      throw WindowsException(HRESULT_FROM_WIN32(result), message: operation);
    }
  }
}
