import 'dart:convert';

import 'package:path/path.dart' as p;

import '../../features/power/domain/game_folder_policy.dart';
import 'operation.dart';

/// Runs a PowerShell script and returns its trimmed output; throws on error.
typedef PowerShellOutput = Future<String> Function(String script);

/// Microsoft Defender state that decides whether an exclusion makes sense.
class DefenderStatus {
  const DefenderStatus({
    required this.mode,
    required this.realTime,
    required this.localExclusionsIgnored,
  });

  /// `AMRunningMode`: Normal when Defender is the active antivirus.
  final String mode;
  final bool realTime;

  /// A policy (`DisableLocalAdminMerge`) makes Defender ignore exclusions
  /// added on this PC.
  final bool localExclusionsIgnored;

  static const script = r'''
$ErrorActionPreference = 'Stop'
$s = Get-MpComputerStatus
$ignored = $false
foreach ($k in 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender',
               'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Defender') {
  $v = (Get-ItemProperty -LiteralPath $k -Name DisableLocalAdminMerge -ErrorAction SilentlyContinue).DisableLocalAdminMerge
  if ($v -eq 1) { $ignored = $true }
}
[pscustomobject]@{ Mode = [string]$s.AMRunningMode; RealTime = [bool]$s.RealTimeProtectionEnabled; Ignored = $ignored } | ConvertTo-Json -Compress
''';

  static Future<DefenderStatus> read(PowerShellOutput run) async =>
      parse(await run(script));

  static DefenderStatus parse(String output) {
    final json = jsonDecode(output);
    if (json is! Map ||
        json['Mode'] is! String ||
        json['RealTime'] is! bool ||
        json['Ignored'] is! bool) {
      throw const FormatException('Unexpected Defender status.');
    }
    return DefenderStatus(
      mode: json['Mode'] as String,
      realTime: json['RealTime'] as bool,
      localExclusionsIgnored: json['Ignored'] as bool,
    );
  }

  /// English reason why an exclusion would not work, or null.
  String? get blocker {
    if (mode != 'Normal') {
      return 'Microsoft Defender is not the active antivirus ($mode).';
    }
    if (!realTime) return 'Defender real-time protection is off.';
    if (localExclusionsIgnored) {
      return 'A policy makes Defender ignore exclusions added on this PC.';
    }
    return null;
  }
}

/// Adds or removes one Defender `ExclusionPath` for the folder of one game.
///
/// Only folder exclusions, never process or extension ones. The rollback
/// touches only the path of the request, so the user's other exclusions are
/// never read into the journal nor changed. Never part of a preset.
class DefenderGameFolderExclusionOperation implements OperationDefinition {
  const DefenderGameFolderExclusionOperation({
    required this.powerShell,
    required this.facts,
  });

  static const operationId = 'defender.exclusion.game_folder';

  final PowerShellOutput powerShell;
  final GameFolderFacts Function() facts;

  /// Validated request: the folder and whether it must be excluded.
  ({String path, bool exclude}) _parse(OperationRequest request) {
    final target = request.target;
    final desired = request.desiredValue;
    if (target == null ||
        target.length > 1024 ||
        target.runes.any((r) => r < 32) ||
        // Defender reads these as wildcards and environment variables.
        target.contains(RegExp(r'[*?%]')) ||
        desired is! bool) {
      throw StateError('Invalid Defender exclusion request.');
    }
    if (!desired) {
      // Removing is always allowed for a well-formed local folder path, even
      // if the folder no longer exists.
      if (!RegExp(r'^[A-Za-z]:\\.').hasMatch(target) ||
          p.windows.normalize(target) != target) {
        throw StateError('Invalid Defender exclusion path.');
      }
      return (path: target, exclude: false);
    }
    final check = _checkFolder(target);
    if (check.warning != null &&
        request.parameters['acknowledgedWarning'] != check.warning!.name) {
      throw StateError('Launcher or library folders need a second consent.');
    }
    return (path: target, exclude: true);
  }

  /// Every path that may become an exclusion passes here, rollbacks included:
  /// the helper also accepts rollback requests with a caller-made snapshot.
  GameFolderCheck _checkFolder(String path) {
    final check = checkGameFolder(path, facts());
    if (!check.allowed) {
      throw StateError('Folder refused: ${check.refusal!.name}.');
    }
    if (check.path != path) {
      throw StateError('The folder path must be given in its final form.');
    }
    return check;
  }

  /// Runs [script] with `$arg` set to [path]; the path travels as base64 and
  /// is never parsed as PowerShell code.
  Future<String> _withPath(String script, String path) {
    final payload = base64Encode(utf8.encode(path));
    return powerShell(
      "\$ErrorActionPreference = 'Stop'\n"
      "\$arg = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload'))\n"
      '$script',
    );
  }

  static const _listScript =
      r"$p = @((Get-MpPreference).ExclusionPath | Where-Object { $_ }); ConvertTo-Json -Compress -InputObject $p";

  /// True when [path] is one of the Defender path exclusions. Needs
  /// administrator rights: without them Defender hides the list.
  Future<bool> _present(String path) async {
    final list = jsonDecode(await powerShell(_listScript));
    if (list is! List || list.any((item) => item is! String)) {
      throw const FormatException('Unexpected Defender exclusion list.');
    }
    if (list.any((item) => (item as String).startsWith('N/A'))) {
      throw StateError('Administrator rights are needed to read exclusions.');
    }
    return list.any((item) => p.windows.equals(item as String, path));
  }

  Future<void> _set(String path, bool exclude) async {
    try {
      await _withPath(
        exclude
            ? r'Add-MpPreference -ExclusionPath $arg'
            : r'Remove-MpPreference -ExclusionPath $arg',
        path,
      );
    } catch (error) {
      throw StateError(
        'Defender refused the change. Tamper Protection or an organization '
        'policy may lock exclusions. ($error)',
      );
    }
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 10240 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 10 or 11 x64.');
    }
    try {
      final (path: _, :exclude) = _parse(request);
      if (exclude) {
        final blocker = (await DefenderStatus.read(powerShell)).blocker;
        if (blocker != null) return SupportResult.unsupported(blocker);
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final path = request.target;
      if (path == null) throw StateError('Missing folder.');
      return OperationState(
        OperationStateKind.configured,
        value: await _present(path),
      );
    } catch (error) {
      return OperationState(OperationStateKind.error, message: '$error');
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final (:path, exclude: _) = _parse(request);
    final present = await _present(path);
    return OperationSnapshot(
      type: 'defenderExclusion',
      data: <String, Object?>{'path': path, 'present': present},
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: present,
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final (:path, :exclude) = _parse(request);
    if (await _present(path) != exclude) await _set(path, exclude);
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final path = request.target;
    final present = snapshot.data['present'];
    if (snapshot.type != 'defenderExclusion' ||
        path == null ||
        snapshot.data['path'] != path ||
        present is! bool) {
      throw StateError('Invalid Defender exclusion snapshot.');
    }
    // Format and wildcard checks; removing needs no existing folder.
    _parse(
      OperationRequest(operationId: id, target: path, desiredValue: false),
    );
    // A launcher warning was already accepted when the exclusion was made.
    if (present) _checkFolder(path);
    if (await _present(path) != present) await _set(path, present);
  }

  @override
  String get id => operationId;
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'gameFolderExclusionTitle';
  @override
  String get descriptionKey => 'gameFolderExclusionDescription';
  @override
  String get domain => 'security';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.machine;
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
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/defender-endpoint/configure-extension-file-exclusions-microsoft-defender-antivirus',
    'https://learn.microsoft.com/powershell/module/defender/add-mppreference',
    'https://learn.microsoft.com/defender-endpoint/configure-local-policy-overrides-microsoft-defender-antivirus',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
