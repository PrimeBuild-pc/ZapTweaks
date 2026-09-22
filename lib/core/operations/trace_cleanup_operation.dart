import 'dart:io';

import '../../platform/windows/cleanup_preview.dart';
import 'operation.dart';

Directory defaultTraceDirectory() => Directory(
  '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}'
  '${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Traces',
);

class TraceCleanupOperation implements OperationDefinition {
  TraceCleanupOperation({
    Directory? directory,
    this.scanner = const CleanupScanner(),
  }) : directory = directory ?? defaultTraceDirectory();

  final Directory directory;
  final CleanupScanner scanner;

  void _validate(OperationRequest request) {
    if (request.target != null ||
        request.desiredValue != true ||
        request.parameters.isNotEmpty) {
      throw StateError('Invalid trace cleanup request.');
    }
  }

  Future<CleanupPreview> _scan() => scanner.scanDirectory(
    directory,
    category: 'ZapTweaks traces',
    reason: 'User-requested diagnostic trace cleanup',
  );

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _validate(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      _validate(request);
      final preview = await _scan();
      return OperationState(
        preview.candidates.isEmpty
            ? OperationStateKind.absent
            : OperationStateKind.configured,
        value: <String, Object>{
          'fileCount': preview.candidates.length,
          'totalBytes': preview.totalBytes,
        },
      );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    _validate(request);
    final before = await inspect(request);
    return OperationSnapshot(
      type: 'irreversibleCleanupPreview',
      data: <String, Object?>{'before': before.value},
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    _validate(request);
    final preview = await _scan();
    for (final candidate in preview.candidates) {
      final file = File(candidate.path);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) async {
    final state = await inspect(request);
    return state.kind == OperationStateKind.absent
        ? const OperationState(OperationStateKind.configured, value: true)
        : const OperationState(
            OperationStateKind.error,
            message: 'One or more trace files could not be removed.',
          );
  }

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('Deleted diagnostic traces cannot be restored.');

  @override
  String get id => 'diagnostics.trace.cleanup';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'cleanupDiagnosticTraces';
  @override
  String get descriptionKey => 'cleanupDiagnosticTracesDescription';
  @override
  String get domain => 'cleanup';
  @override
  String get destination => 'Diagnostics & Recovery';
  @override
  OperationScope get scope => OperationScope.user;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.runtimeObserved;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.documented;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows-hardware/test/wpt/windows-performance-recorder',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>['diagnostics.etw.capture'];
}
