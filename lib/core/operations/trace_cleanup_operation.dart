import 'dart:io';

import 'package:path/path.dart' as p;

import '../../platform/windows/cleanup_preview.dart';
import '../services/process_runner.dart';
import 'operation.dart';

Directory defaultTraceDirectory() => Directory(
  '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}'
  '${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Traces',
);

class TraceCleanupOperation
    implements OperationDefinition, SnapshotApplyOperation {
  TraceCleanupOperation({
    Directory? directory,
    this.scanner = const CleanupScanner(),
  }) : directory = directory ?? defaultTraceDirectory();

  final Directory directory;
  final CleanupScanner scanner;

  /// The fixed root a previewed file must stay in.
  Directory rootFor(CleanupCandidate candidate) => directory;

  void _validate(OperationRequest request) {
    if (request.operationId != id ||
        request.target != null ||
        request.desiredValue != true ||
        request.parameters.length != 1 ||
        request.parameters['preview'] is! List) {
      throw StateError('Invalid trace cleanup request.');
    }
  }

  List<CleanupCandidate> _requestedPreview(OperationRequest request) {
    _validate(request);
    final paths = <String>{};
    return (request.parameters['preview']! as List)
        .map((row) {
          final candidate = CleanupCandidate.fromJson(row);
          scanner.validatePath(rootFor(candidate), candidate);
          if (!paths.add(candidate.path.toLowerCase())) {
            throw StateError('Duplicate trace cleanup identity.');
          }
          return candidate;
        })
        .toList(growable: false);
  }

  Future<CleanupPreview> _frozenPreview(OperationRequest request) async {
    final requested = _requestedPreview(request);
    // Inspect only approved identities; never widen the snapshot by rescanning.
    for (final candidate in requested) {
      scanner.checkCandidate(rootFor(candidate), candidate);
    }
    return CleanupPreview(requested);
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      await _frozenPreview(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final preview = await _frozenPreview(request);
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
    final preview = await _frozenPreview(request);
    final before = OperationState(
      preview.candidates.isEmpty
          ? OperationStateKind.absent
          : OperationStateKind.configured,
      value: <String, Object>{
        'fileCount': preview.candidates.length,
        'totalBytes': preview.totalBytes,
      },
    );
    return OperationSnapshot(
      type: 'irreversibleCleanupPreview',
      data: <String, Object?>{
        'candidates': <Map<String, Object?>>[
          for (final candidate in preview.candidates) candidate.toJson(),
        ],
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) => throw UnsupportedError(
    'Trace cleanup must apply the immutable plan snapshot.',
  );

  @override
  Future<void> applySnapshot(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final approved = _requestedPreview(request);
    if (snapshot.type != 'irreversibleCleanupPreview' ||
        snapshot.data.length != 1 ||
        snapshot.data['candidates'] is! List) {
      throw StateError('Invalid trace cleanup snapshot.');
    }
    final frozenRequest = OperationRequest(
      operationId: request.operationId,
      desiredValue: request.desiredValue,
      target: request.target,
      parameters: <String, Object?>{'preview': snapshot.data['candidates']},
    );
    final candidates = _requestedPreview(frozenRequest);
    if (!OperationState(
      OperationStateKind.configured,
      value: approved.map((item) => item.toJson()).toList(),
    ).sameValue(
      OperationState(
        OperationStateKind.configured,
        value: candidates.map((item) => item.toJson()).toList(),
      ),
    )) {
      throw StateError('Cleanup snapshot does not match the approved preview.');
    }
    for (final candidate in candidates) {
      scanner.checkCandidate(rootFor(candidate), candidate);
    }
    for (final candidate in candidates) {
      scanner.checkCandidate(rootFor(candidate), candidate, delete: true);
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) async {
    try {
      final candidates = _requestedPreview(request);
      final remaining = <String>[];
      for (final candidate in candidates) {
        if (!scanner.isAbsent(rootFor(candidate), candidate)) {
          remaining.add(candidate.path);
        }
      }
      return remaining.isEmpty
          ? const OperationState(OperationStateKind.configured, value: true)
          : const OperationState(
              OperationStateKind.error,
              message:
                  'One or more previewed trace files could not be removed.',
            );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('Deleted diagnostic traces cannot be restored.');

  @override
  String get id => 'diagnostics.trace.cleanup';
  @override
  int get version => 3;
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

class UserTempCleanupOperation extends TraceCleanupOperation {
  UserTempCleanupOperation({Directory? directory, super.scanner})
    : super(directory: directory ?? defaultUserTempDirectory());

  @override
  String get id => 'cleanup.user_temp';
  @override
  String get titleKey => 'cleanupUserTemp';
  @override
  String get descriptionKey => 'cleanupUserTempDescription';
  @override
  List<String> get technicalSources => const [
    'https://learn.microsoft.com/windows/win32/fileio/file-management-functions',
  ];
  @override
  List<String> get conflicts => const [];
  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('Deleted temporary files cannot be restored.');
}

String _localAppData() {
  final local = Platform.environment['LOCALAPPDATA'];
  if (!Platform.isWindows || local == null || local.isEmpty) {
    throw UnsupportedError(
      'Cleanup folders are unavailable: no Windows user profile.',
    );
  }
  return local;
}

/// GPU driver shader caches of the current user. The driver rebuilds them; no Prefetch or Windows Update cache.
List<Directory> defaultShaderCacheDirectories() {
  final local = _localAppData();
  final profile = Platform.environment['USERPROFILE'];
  if (profile == null || profile.isEmpty) {
    throw UnsupportedError(
      'Shader caches are unavailable: no Windows user profile.',
    );
  }
  final low = p.join(profile, 'AppData', 'LocalLow');
  return <Directory>[
    for (final path in const <String>[
      'D3DSCache',
      r'AMD\DxCache',
      r'AMD\DxcCache',
      r'AMD\DX9Cache',
      r'AMD\VkCache',
      r'AMD\GLCache',
      r'AMD\OglCache',
      r'NVIDIA\DXCache',
      r'NVIDIA\GLCache',
      r'Intel\ShaderCache',
    ])
      Directory(p.join(local, path)),
    for (final path in const <String>[
      r'AMD\DxCache',
      r'AMD\DxcCache',
      r'AMD\VkCache',
      r'NVIDIA\PerDriverVersion\DXCache',
      r'NVIDIA\PerDriverVersion\GLCache',
      r'Intel\ShaderCache',
    ])
      Directory(p.join(low, path)),
  ];
}

/// Crash dumps of user programs and the user's Windows Error Reporting archive and queue.
/// System minidumps (C:\Windows\Minidump) need administrator rights and stay out.
List<Directory> defaultCrashReportDirectories() {
  final local = _localAppData();
  return <Directory>[
    for (final path in const <String>[
      'CrashDumps',
      r'Microsoft\Windows\WER\ReportArchive',
      r'Microsoft\Windows\WER\ReportQueue',
    ])
      Directory(p.join(local, path)),
  ];
}

/// Disk caches of Chromium browsers (every profile) and Firefox. Cookies, history and passwords live elsewhere.
List<Directory> defaultBrowserCacheDirectories() {
  final local = _localAppData();
  List<Directory> children(String path) {
    final directory = Directory(path);
    return directory.existsSync()
        ? directory.listSync(followLinks: false).whereType<Directory>().toList()
        : <Directory>[];
  }

  return <Directory>[
    for (final base in const <String>[
      r'Google\Chrome\User Data',
      r'Microsoft\Edge\User Data',
      r'BraveSoftware\Brave-Browser\User Data',
    ])
      for (final profile in children(p.join(local, base)))
        if (isChromiumProfile(p.basename(profile.path)))
          for (final cache in const <String>[
            r'Cache\Cache_Data',
            'Code Cache',
            'GPUCache',
          ])
            Directory(p.join(profile.path, cache)),
    for (final profile in children(p.join(local, r'Mozilla\Firefox\Profiles')))
      Directory(p.join(profile.path, 'cache2')),
  ];
}

bool isChromiumProfile(String name) =>
    name == 'Default' ||
    name == 'Guest Profile' ||
    RegExp(r'^Profile \d+$').hasMatch(name);

/// A cleanup over a fixed allowlist of folders: every previewed file must stay in the folder it was found in.
abstract class FixedRootsCleanupOperation extends TraceCleanupOperation {
  // The inherited single directory is unused.
  FixedRootsCleanupOperation(this.roots, {super.scanner});

  final List<Directory> Function() roots;
  List<Directory>? _cached;

  Directory? _match(List<Directory> list, CleanupCandidate candidate) {
    for (final root in list) {
      if (p.equals(p.normalize(root.absolute.path), candidate.rootCanonical)) {
        return root;
      }
    }
    return null;
  }

  // Cached; read again on a miss, so a browser profile created after start-up is still accepted.
  @override
  Directory rootFor(CleanupCandidate candidate) =>
      _match(_cached ??= roots(), candidate) ??
      _match(_cached = roots(), candidate) ??
      (throw StateError('Cleanup preview escapes its fixed directories.'));

  // Validated on synthetic directories only; the locations come from vendor and Windows documentation.
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  List<String> get conflicts => const [];
}

class ShaderCacheCleanupOperation extends FixedRootsCleanupOperation {
  ShaderCacheCleanupOperation({List<Directory>? directories, super.scanner})
    : super(
        directories == null ? defaultShaderCacheDirectories : () => directories,
      );

  @override
  String get id => 'cleanup.shader_cache';
  @override
  String get titleKey => 'cleanupShaderCache';
  @override
  String get descriptionKey => 'cleanupShaderCacheDescription';
  @override
  List<String> get technicalSources => const [
    'https://learn.microsoft.com/windows/win32/api/d3d12/nf-d3d12-id3d12device9-createshadercachesession',
    'https://learn.microsoft.com/windows/win32/lwef/disk-cleanup',
    'https://learn.microsoft.com/windows-server/administration/windows-commands/cleanmgr',
  ];
  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError(
        'Deleted shader caches cannot be restored; the driver rebuilds them.',
      );
}

class CrashReportCleanupOperation extends FixedRootsCleanupOperation {
  CrashReportCleanupOperation({List<Directory>? directories, super.scanner})
    : super(
        directories == null ? defaultCrashReportDirectories : () => directories,
      );

  @override
  String get id => 'cleanup.crash_reports';
  @override
  String get titleKey => 'cleanupCrashReports';
  @override
  String get descriptionKey => 'cleanupCrashReportsDescription';
  @override
  List<String> get technicalSources => const [
    'https://learn.microsoft.com/windows/win32/wer/collecting-user-mode-dumps',
    'https://learn.microsoft.com/windows/win32/wer/wer-settings',
  ];
  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError(
        'Deleted crash dumps and error reports cannot be restored.',
      );
}

class BrowserCacheCleanupOperation extends FixedRootsCleanupOperation {
  BrowserCacheCleanupOperation({List<Directory>? directories, super.scanner})
    : super(
        directories == null
            ? defaultBrowserCacheDirectories
            : () => directories,
      );

  @override
  String get id => 'cleanup.browser_cache';
  @override
  String get titleKey => 'cleanupBrowserCache';
  @override
  String get descriptionKey => 'cleanupBrowserCacheDescription';
  @override
  List<String> get technicalSources => const [
    'https://www.chromium.org/user-experience/user-data-directory/',
    'https://support.mozilla.org/kb/profiles-where-firefox-stores-user-data',
  ];
  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError(
        'Deleted browser caches cannot be restored; browsers rebuild them.',
      );
}

const Map<String, String> _browserProcesses = <String, String>{
  'chrome.exe': 'Chrome',
  'msedge.exe': 'Edge',
  'brave.exe': 'Brave',
  'firefox.exe': 'Firefox',
};

/// Browsers among the running processes, from `tasklist /FO CSV /NH` output.
List<String> parseRunningBrowsers(String tasklistCsv) {
  final names = <String>{};
  for (final line in tasklistCsv.split(RegExp(r'\r?\n'))) {
    if (!line.startsWith('"')) continue;
    final end = line.indexOf('"', 1);
    if (end < 0) continue;
    final name = _browserProcesses[line.substring(1, end).toLowerCase()];
    if (name != null) names.add(name);
  }
  return names.toList()..sort();
}

/// Browsers that are open now: their caches must not be deleted underneath them.
Future<List<String>> runningBrowsers() async {
  final result = await Process.run(
    ProcessRunner.resolveSystemExecutable('tasklist.exe'),
    const <String>['/FO', 'CSV', '/NH'],
  );
  if (result.exitCode != 0) {
    throw StateError(
      'Cannot list running programs (tasklist ${result.exitCode}).',
    );
  }
  return parseRunningBrowsers(result.stdout as String);
}
