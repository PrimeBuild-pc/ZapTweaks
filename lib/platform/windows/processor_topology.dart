import 'dart:ffi';

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

class ProcessorTopology {
  const ProcessorTopology({required this.processorsPerGroup});

  final Map<int, int> processorsPerGroup;

  int get logicalProcessorCount =>
      processorsPerGroup.values.fold(0, (a, b) => a + b);

  Set<ProcessorAddress> get addresses => <ProcessorAddress>{
    for (final entry in processorsPerGroup.entries)
      for (var number = 0; number < entry.value; number++)
        ProcessorAddress(
          entry.key,
          number,
          numaNode: _numaNode(entry.key, number),
        ),
  };

  static final _GetNumaProcessorNodeExDart _getNumaProcessorNodeEx =
      DynamicLibrary.open('kernel32.dll').lookupFunction<
        _GetNumaProcessorNodeExNative,
        _GetNumaProcessorNodeExDart
      >('GetNumaProcessorNodeEx');

  static ProcessorTopology inspect() {
    final groups = GetActiveProcessorGroupCount();
    if (groups < 1) throw StateError('Windows reported no processor groups.');
    final counts = <int, int>{};
    for (var group = 0; group < groups; group++) {
      final count = GetActiveProcessorCount(group);
      if (count < 1) throw StateError('Processor group $group is empty.');
      counts[group] = count;
    }
    return ProcessorTopology(processorsPerGroup: Map.unmodifiable(counts));
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
