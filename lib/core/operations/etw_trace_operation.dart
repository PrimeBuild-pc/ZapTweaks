import 'dart:io';

import '../../platform/windows/etw_trace_collector.dart';
import 'operation.dart';

class EtwTraceOperation implements OperationDefinition {
  EtwTraceOperation({required this.collector, Directory? outputDirectory})
    : outputDirectory =
          outputDirectory ??
          Directory(
            '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}'
            '${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Traces',
          );

  final EtwTraceCollector collector;
  final Directory outputDirectory;
  String? _lastTrace;

  int _duration(OperationRequest request) {
    if (request.target != null || request.desiredValue != true) {
      throw StateError('Invalid ETW capture request.');
    }
    final seconds = request.parameters['durationSeconds'];
    if (request.parameters.length != 1 ||
        seconds is! int ||
        seconds < 5 ||
        seconds > 120) {
      throw StateError('ETW duration must be between 5 and 120 seconds.');
    }
    return seconds;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      _duration(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      _duration(request);
      final path = _lastTrace;
      if (path == null) return const OperationState(OperationStateKind.absent);
      final file = File(path);
      return await file.exists() && await file.length() > 0
          ? OperationState(OperationStateKind.configured, value: path)
          : const OperationState(
              OperationStateKind.error,
              message: 'ETW trace is missing or empty.',
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
    _duration(request);
    return const OperationSnapshot(
      type: 'diagnosticCapture',
      data: <String, Object?>{},
      expectedAfterRollback: OperationState(OperationStateKind.absent),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final trace = await collector.capture(
      directory: outputDirectory,
      duration: Duration(seconds: _duration(request)),
    );
    _lastTrace = trace.path;
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);
  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('Diagnostic captures are not reversible.');
  @override
  String get id => 'diagnostics.etw.capture';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'captureEtwTrace';
  @override
  String get descriptionKey => 'captureEtwTraceDescription';
  @override
  String get domain => 'diagnostics';
  @override
  String get destination => 'Diagnostics & Recovery';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;
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
  List<String> get conflicts => const <String>[];
}
