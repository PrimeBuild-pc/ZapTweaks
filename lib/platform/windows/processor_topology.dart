import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'hardware_capability_validators.dart';

final class _ProcessorNumber extends Struct {
  @Uint16()
  external int group;

  @Uint8()
  external int number;

  @Uint8()
  external int reserved;
}

typedef _GetNumaProcessorNodeExNative =
    Int32 Function(Pointer<_ProcessorNumber>, Pointer<Uint16>);
typedef _GetNumaProcessorNodeExDart =
    int Function(Pointer<_ProcessorNumber>, Pointer<Uint16>);
typedef _GetSystemCpuSetInformationNative =
    Int32 Function(Pointer<Uint8>, Uint32, Pointer<Uint32>, IntPtr, Uint32);
typedef _GetSystemCpuSetInformationDart =
    int Function(Pointer<Uint8>, int, Pointer<Uint32>, int, int);
typedef _GetLogicalProcessorInformationExNative =
    Int32 Function(Int32, Pointer<Uint8>, Pointer<Uint32>);
typedef _GetLogicalProcessorInformationExDart =
    int Function(int, Pointer<Uint8>, Pointer<Uint32>);

class ProcessorTopology {
  const ProcessorTopology({
    required this.processorsPerGroup,
    Set<ProcessorAddress>? processors,
    this.lastLevelCacheBytes = const <int, int>{},
  }) : _processors = processors;

  final Map<int, int> processorsPerGroup;

  /// Size of each last-level cache, keyed like
  /// [ProcessorAddress.lastLevelCacheIndex]; empty when unknown.
  final Map<int, int> lastLevelCacheBytes;
  final Set<ProcessorAddress>? _processors;

  int get logicalProcessorCount =>
      processorsPerGroup.values.fold(0, (a, b) => a + b);

  bool get detailsAvailable => _processors != null;

  Set<ProcessorAddress> get addresses =>
      _processors ??
      <ProcessorAddress>{
        for (final entry in processorsPerGroup.entries)
          for (var number = 0; number < entry.value; number++)
            ProcessorAddress(
              entry.key,
              number,
              numaNode: _numaNode(entry.key, number),
            ),
      };

  bool get hasSmt => _groupsByCore.values.any((threads) => threads.length > 1);

  bool get hasHeterogeneousCores =>
      addresses
          .map((item) => item.efficiencyClass)
          .whereType<int>()
          .toSet()
          .length >
      1;

  Set<ProcessorAddress> get primaryThreads => <ProcessorAddress>{
    for (final threads in _groupsByCore.values)
      (threads.toList()..sort((a, b) => a.number.compareTo(b.number))).first,
  };

  Set<ProcessorAddress> get performanceCores {
    final classes = addresses
        .map((item) => item.efficiencyClass)
        .whereType<int>()
        .toSet();
    if (classes.length < 2) return const <ProcessorAddress>{};
    final fastest = classes.reduce((a, b) => a > b ? a : b);
    return addresses.where((item) => item.efficiencyClass == fastest).toSet();
  }

  Set<ProcessorAddress> get efficiencyCores {
    final classes = addresses
        .map((item) => item.efficiencyClass)
        .whereType<int>()
        .toSet();
    if (classes.length < 2) return const <ProcessorAddress>{};
    final mostEfficient = classes.reduce((a, b) => a < b ? a : b);
    return addresses
        .where((item) => item.efficiencyClass == mostEfficient)
        .toSet();
  }

  Map<int, Set<ProcessorAddress>> addressesByLastLevelCache(int group) =>
      _groupBy(
        addresses.where((item) => item.group == group),
        (item) => item.lastLevelCacheIndex,
      );

  Map<int, Set<ProcessorAddress>> addressesByNumaNode(int group) => _groupBy(
    addresses.where((item) => item.group == group),
    (item) => item.numaNode,
  );

  Map<String, Set<ProcessorAddress>> get _groupsByCore {
    final result = <String, Set<ProcessorAddress>>{};
    for (final processor in addresses) {
      final core = processor.coreIndex;
      if (core == null) continue;
      result.putIfAbsent('${processor.group}/$core', () => {}).add(processor);
    }
    return result;
  }

  static Map<int, Set<ProcessorAddress>> _groupBy(
    Iterable<ProcessorAddress> processors,
    int? Function(ProcessorAddress) keyOf,
  ) {
    final result = <int, Set<ProcessorAddress>>{};
    for (final processor in processors) {
      final key = keyOf(processor);
      if (key != null) result.putIfAbsent(key, () => {}).add(processor);
    }
    return result;
  }

  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final _GetNumaProcessorNodeExDart _getNumaProcessorNodeEx = _kernel32
      .lookupFunction<
        _GetNumaProcessorNodeExNative,
        _GetNumaProcessorNodeExDart
      >('GetNumaProcessorNodeEx');
  static final _GetSystemCpuSetInformationDart _getSystemCpuSetInformation =
      _kernel32.lookupFunction<
        _GetSystemCpuSetInformationNative,
        _GetSystemCpuSetInformationDart
      >('GetSystemCpuSetInformation');
  static final _GetLogicalProcessorInformationExDart
  _getLogicalProcessorInformationEx = _kernel32
      .lookupFunction<
        _GetLogicalProcessorInformationExNative,
        _GetLogicalProcessorInformationExDart
      >('GetLogicalProcessorInformationEx');

  static ProcessorTopology inspect() {
    final groups = GetActiveProcessorGroupCount();
    if (groups < 1) throw StateError('Windows reported no processor groups.');
    final counts = <int, int>{};
    for (var group = 0; group < groups; group++) {
      final count = GetActiveProcessorCount(group);
      if (count < 1) throw StateError('Processor group $group is empty.');
      counts[group] = count;
    }
    final processors = _readCpuSets();
    final complete = processors.length == counts.values.fold(0, (a, b) => a + b)
        ? Set<ProcessorAddress>.unmodifiable(processors)
        : null;
    return ProcessorTopology(
      processorsPerGroup: Map.unmodifiable(counts),
      processors: complete,
      lastLevelCacheBytes: complete == null
          ? const <int, int>{}
          : Map.unmodifiable(
              parseLastLevelCacheBytes(_readCacheRelations(), complete),
            ),
    );
  }

  static ByteData _readCacheRelations() {
    final required = calloc<Uint32>();
    try {
      _getLogicalProcessorInformationEx(RelationCache, nullptr, required);
      if (required.value == 0) return ByteData(0);
      final buffer = calloc<Uint8>(required.value);
      try {
        if (_getLogicalProcessorInformationEx(
              RelationCache,
              buffer,
              required,
            ) ==
            FALSE) {
          return ByteData(0);
        }
        return ByteData.sublistView(
          Uint8List.fromList(buffer.asTypedList(required.value)),
        );
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(required);
    }
  }

  /// Unified level-3 cache sizes from `SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX`
  /// cache records, keyed by the last-level-cache index of their processors.
  static Map<int, int> parseLastLevelCacheBytes(
    ByteData data,
    Set<ProcessorAddress> processors,
  ) {
    final result = <int, int>{};
    var offset = 0;
    while (offset + 8 <= data.lengthInBytes) {
      final size = data.getUint32(offset + 4, Endian.little);
      if (size < 56 || offset + size > data.lengthInBytes) break;
      final relationship = data.getUint32(offset, Endian.little);
      final level = data.getUint8(offset + 8);
      final type = data.getUint32(offset + 16, Endian.little);
      if (relationship == RelationCache && level == 3 && type == 0) {
        final bytes = data.getUint32(offset + 12, Endian.little);
        final groups = data.getUint16(offset + 38, Endian.little);
        for (var index = 0; index < (groups == 0 ? 1 : groups); index++) {
          final at = offset + 40 + index * 16;
          if (at + 16 > offset + size) break;
          final mask = data.getUint64(at, Endian.little);
          final group = data.getUint16(at + 8, Endian.little);
          for (final processor in processors) {
            final cache = processor.lastLevelCacheIndex;
            if (cache != null &&
                processor.group == group &&
                processor.number < 64 &&
                (mask >> processor.number) & 1 == 1) {
              result[cache] = bytes;
            }
          }
        }
      }
      offset += size;
    }
    return result;
  }

  static Set<ProcessorAddress> _readCpuSets() {
    final required = calloc<Uint32>();
    try {
      _getSystemCpuSetInformation(nullptr, 0, required, 0, 0);
      if (required.value < 32) return const <ProcessorAddress>{};
      final buffer = calloc<Uint8>(required.value);
      try {
        if (_getSystemCpuSetInformation(
              buffer,
              required.value,
              required,
              0,
              0,
            ) ==
            FALSE) {
          return const <ProcessorAddress>{};
        }
        final data = ByteData.sublistView(buffer.asTypedList(required.value));
        final processors = <ProcessorAddress>{};
        var offset = 0;
        while (offset + 32 <= data.lengthInBytes) {
          final size = data.getUint32(offset, Endian.little);
          if (size < 32 || offset + size > data.lengthInBytes) break;
          final type = data.getUint32(offset + 4, Endian.little);
          if (type == 0) {
            processors.add(
              ProcessorAddress(
                data.getUint16(offset + 12, Endian.little),
                data.getUint8(offset + 14),
                coreIndex: data.getUint8(offset + 15),
                lastLevelCacheIndex: data.getUint8(offset + 16),
                numaNode: data.getUint8(offset + 17),
                efficiencyClass: data.getUint8(offset + 18),
                parked: data.getUint8(offset + 19) & 1 != 0,
              ),
            );
          }
          offset += size;
        }
        return processors;
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(required);
    }
  }

  static int? _numaNode(int group, int number) => using((arena) {
    final processor = arena<_ProcessorNumber>()
      ..ref.group = group
      ..ref.number = number
      ..ref.reserved = 0;
    final node = arena<Uint16>();
    return _getNumaProcessorNodeEx(processor, node) == FALSE
        ? null
        : node.value;
  });
}
