import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../platform/windows/power_plan_file_service.dart';
import '../../platform/windows/power_scheme_service.dart';
import '../services/process_runner.dart';
import 'operation.dart';

class PowerSchemesRestoreDefaultsOperation implements OperationDefinition {
  PowerSchemesRestoreDefaultsOperation({
    required this.files,
    required this.schemes,
    required this.processRunner,
    Directory? backupRoot,
    Future<void> Function(Directory)? secureDirectory,
  }) : secureDirectory = secureDirectory ?? _secure,
       backupRoot =
           backupRoot ??
           Directory(
             path.join(
               Platform.environment['LOCALAPPDATA'] ??
                   Directory.systemTemp.path,
               'ZapTweaks',
               'Helper',
               'PowerSchemeDefaultsBackups',
             ),
           );

  static const _balanced = '{381b4222-f694-41f0-9685-ff5bb260df2e}';
  final PowerPlanFileService files;
  final PowerSchemeAdministration schemes;
  final ProcessRunner processRunner;
  final Directory backupRoot;
  final Future<void> Function(Directory) secureDirectory;

  void _validate(OperationRequest request) {
    if (request.target != null ||
        request.desiredValue != true ||
        request.parameters.isNotEmpty) {
      throw StateError('Invalid restore-default-schemes request.');
    }
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _validate(request);
      return context.windowsBuild >= 22000 && context.architecture == 'x64'
          ? const SupportResult.supported()
          : const SupportResult.unsupported('Requires Windows 11 x64.');
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      _validate(request);
      final ids = schemes.enumerate().map((scheme) => scheme.id).toSet();
      return ids.contains(_balanced)
          ? const OperationState(OperationStateKind.configured, value: true)
          : const OperationState(OperationStateKind.absent);
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
    final before = schemes.enumerate();
    if (before.isEmpty) throw StateError('No power schemes are available.');
    await backupRoot.create(recursive: true);
    await secureDirectory(backupRoot);
    final random = Random.secure();
    final directory = Directory(
      path.join(
        backupRoot.path,
        List<int>.generate(
          16,
          (_) => random.nextInt(256),
        ).map((value) => value.toRadixString(16).padLeft(2, '0')).join(),
      ),
    );
    await directory.create();
    final backups = <Map<String, Object>>[];
    try {
      for (final scheme in before) {
        final file = File(path.join(directory.path, '${_bare(scheme.id)}.pow'));
        await files.exportScheme(scheme.id, file);
        backups.add(<String, Object>{
          'id': scheme.id,
          'path': file.path,
          'sha256': await _hash(file),
        });
      }
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
    return OperationSnapshot(
      type: 'allPowerSchemes',
      data: <String, Object?>{
        'directory': directory.path,
        'activeId': schemes.activeSchemeId,
        'backups': backups,
      },
      expectedAfterRollback: const OperationState(
        OperationStateKind.configured,
        value: true,
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    _validate(request);
    final result = await processRunner.run('powercfg.exe', const <String>[
      '/restoredefaultschemes',
    ]);
    if (!result.success) {
      throw StateError(
        'Restoring default power schemes failed: ${result.details}',
      );
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    _validate(request);
    final directoryValue = snapshot.data['directory'];
    final activeId = snapshot.data['activeId'];
    final rawBackups = snapshot.data['backups'];
    if (snapshot.type != 'allPowerSchemes' ||
        directoryValue is! String ||
        activeId is! String ||
        rawBackups is! List) {
      throw StateError('Invalid all-power-schemes snapshot.');
    }
    final directory = Directory(directoryValue);
    final root = path.canonicalize(backupRoot.absolute.path).toLowerCase();
    final canonicalDirectory = path
        .canonicalize(directory.absolute.path)
        .toLowerCase();
    if (!canonicalDirectory.startsWith('$root${path.separator}') ||
        !await directory.exists()) {
      throw StateError('Power scheme backup is outside the protected root.');
    }
    final backups = rawBackups.cast<Map>();
    for (final backup in backups) {
      final filePath = backup['path'];
      final digest = backup['sha256'];
      if (backup['id'] is! String ||
          filePath is! String ||
          digest is! String ||
          !path
              .canonicalize(filePath)
              .toLowerCase()
              .startsWith('$canonicalDirectory${path.separator}')) {
        throw StateError('Invalid power scheme backup entry.');
      }
      final file = File(filePath);
      if (!await file.exists() || await _hash(file) != digest) {
        throw StateError('Power scheme backup integrity check failed.');
      }
    }

    final current = schemes.enumerate();
    if (current.isEmpty) {
      throw StateError('No staging power scheme is available.');
    }
    final stagingId = schemes.duplicateScheme(
      current.first.id,
      'ZapTweaks rollback staging',
    );
    schemes.setActiveScheme(stagingId);
    for (final scheme in schemes.enumerate()) {
      if (scheme.id != stagingId) {
        schemes.deleteScheme(scheme.id);
      }
    }
    try {
      for (final backup in backups) {
        final id = backup['id']! as String;
        final staging = Directory(
          path.join(directory.path, 'import-${_bare(id)}'),
        );
        await files.importScheme(
          File(backup['path']! as String),
          staging,
          schemeId: id,
        );
        if (await staging.exists()) await staging.delete(recursive: true);
      }
      schemes.setActiveScheme(activeId);
      schemes.deleteScheme(stagingId);
      final restored = schemes.enumerate().map((scheme) => scheme.id).toSet();
      final expected = backups.map((backup) => backup['id']! as String).toSet();
      if (restored.length != expected.length ||
          !restored.containsAll(expected)) {
        throw StateError('Power schemes were not restored exactly.');
      }
      await directory.delete(recursive: true);
    } catch (_) {
      rethrow;
    }
  }

  static String _bare(String id) => id.substring(1, id.length - 1);
  static Future<String> _hash(File file) async =>
      sha256.bind(file.openRead()).first.then((value) => value.toString());

  static Future<void> _secure(Directory directory) async {
    if (!Platform.isWindows) return;
    final domain = Platform.environment['USERDOMAIN'];
    final user = Platform.environment['USERNAME'];
    if (domain == null || user == null) {
      throw StateError('Unable to identify the power backup owner.');
    }
    final result = await Process.run('icacls.exe', <String>[
      directory.path,
      '/inheritance:r',
      '/grant:r',
      '$domain\\$user:(OI)(CI)F',
      '*S-1-5-18:(OI)(CI)F',
      '*S-1-5-32-544:(OI)(CI)F',
    ]);
    if (result.exitCode != 0) {
      throw StateError('Unable to secure the power backup directory.');
    }
  }

  @override
  String get id => 'power.schemes.restore_defaults';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'restoreDefaultPowerSchemes';
  @override
  String get descriptionKey => 'restoreDefaultPowerSchemesDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.powerPlan;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
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
    'https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[
    'power.scheme.activate',
    'power.scheme.delete',
    'power.scheme.import',
  ];
}
