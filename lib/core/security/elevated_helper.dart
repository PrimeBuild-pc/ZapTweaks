import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../models/tweak_descriptor.dart';
import '../operations/operation.dart';
import '../operations/operation_registry.dart';
import '../persistence/operation_store.dart';
import '../plans/operation_plan.dart';
import '../plans/plan_engine.dart';
import '../services/restore_point_service.dart';
import '../services/tweak_catalog_service.dart';
import '../tweak_manager.dart';
import '../../features/apps/application/windows_app_inventory_service.dart';
import '../../features/apps/domain/app_package.dart';

Directory defaultElevatedHelperDirectory() => Directory(
  '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}'
  '${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Helper',
);

typedef HelperLauncher =
    Future<int> Function(
      String executable,
      File request,
      String nonce,
      String digest,
    );
typedef DirectorySecurity = Future<void> Function(Directory directory);

class ElevatedHelperProgress {
  const ElevatedHelperProgress({required this.state, this.operationId});

  final String state;
  final String? operationId;
}

class ElevatedHelperResult {
  const ElevatedHelperResult({
    required this.success,
    this.observed,
    this.message,
  });

  final bool success;
  final bool? observed;
  final String? message;
}

class ElevatedHelperClient {
  ElevatedHelperClient({
    required Directory directory,
    HelperLauncher? launcher,
    DirectorySecurity? secureDirectory,
  }) : _directory = directory,
       _launcher = launcher ?? _launchElevated,
       _secureDirectory = secureDirectory ?? _applyWindowsAcl;

  final Directory _directory;
  final HelperLauncher _launcher;
  final DirectorySecurity _secureDirectory;
  final _progress = StreamController<ElevatedHelperProgress>.broadcast();

  Stream<ElevatedHelperProgress> get progress => _progress.stream;

  Future<ElevatedHelperResult> applySystemTweak({
    required String operationId,
    required bool desiredValue,
    required bool createRestorePoint,
  }) async {
    final json = await _send(<String, Object?>{
      'operationId': operationId,
      'desiredValue': desiredValue,
      'createRestorePoint': createRestorePoint,
    });
    return ElevatedHelperResult(
      success: json['success'] == true,
      observed: json['observed'] as bool?,
      message: json['message'] as String?,
    );
  }

  Future<OperationPlan> executeNativePlan({
    required List<OperationRequest> requests,
    required String user,
    required String appVersion,
  }) async {
    final response = await _send(<String, Object?>{
      'protocol': 'nativePlan',
      'user': user,
      'appVersion': appVersion,
      'requests': requests
          .map(
            (request) => <String, Object?>{
              'operationId': request.operationId,
              'target': request.target,
              'desiredValue': request.desiredValue,
              'parameters': request.parameters,
            },
          )
          .toList(growable: false),
    });
    if (response['success'] != true || response['plan'] is! Map) {
      throw StateError(response['message'] ?? 'Elevated plan failed.');
    }
    return OperationPlan.fromJson(
      Map<String, Object?>.from(response['plan'] as Map),
    );
  }

  Future<AppInventoryResult> scanSystemApps() async {
    final response = await _send(<String, Object?>{'protocol': 'appInventory'});
    if (response['success'] != true || response['result'] is! Map) {
      throw StateError(response['message'] ?? 'Elevated app inventory failed.');
    }
    final result = Map<String, dynamic>.from(response['result'] as Map);
    return AppInventoryResult(
      packages: (result['packages']! as List)
          .map(
            (row) => AppPackage.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList(growable: false),
      currentUserComplete: result['currentUserComplete']! as bool,
      allUsersComplete: result['allUsersComplete']! as bool,
      provisionedComplete: result['provisionedComplete']! as bool,
      wingetComplete: result['wingetComplete']! as bool,
      message: result['message'] as String?,
    );
  }

  Future<void> applyNativeOperation(OperationRequest request) async {
    final response = await _send(<String, Object?>{
      'protocol': 'nativeOperation',
      'action': 'apply',
      'operationId': request.operationId,
      'target': request.target,
      'desiredValue': request.desiredValue,
      'parameters': request.parameters,
    });
    if (response['success'] != true) {
      throw StateError(response['message'] ?? 'Elevated operation failed.');
    }
  }

  Future<void> rollbackNativeOperation(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final response = await _send(<String, Object?>{
      'protocol': 'nativeOperation',
      'action': 'rollback',
      'operationId': request.operationId,
      'target': request.target,
      'desiredValue': request.desiredValue,
      'parameters': request.parameters,
      'snapshot': snapshot.toJson(),
    });
    if (response['success'] != true) {
      throw StateError(response['message'] ?? 'Elevated rollback failed.');
    }
  }

  Future<Map<String, dynamic>> _send(Map<String, Object?> requestData) async {
    await _directory.create(recursive: true);
    await _secureDirectory(_directory);
    final nonce = _nonce();
    final request = File(
      '${_directory.path}${Platform.pathSeparator}$nonce.json',
    );
    final response = File('${request.path}.response');
    final events = File('${request.path}.events');
    final payload = utf8.encode(
      jsonEncode(
        _encodeValue(<String, Object?>{'nonce': nonce, ...requestData}),
      ),
    );
    await request.writeAsBytes(payload, flush: true);
    var seenEvents = 0;
    var readingEvents = false;
    Future<void> readEvents() async {
      if (readingEvents || !await events.exists()) return;
      readingEvents = true;
      try {
        final lines = await events.readAsLines();
        for (final line in lines.skip(seenEvents)) {
          final event = jsonDecode(line) as Map<String, dynamic>;
          _progress.add(
            ElevatedHelperProgress(
              state: event['state'] as String,
              operationId: event['operationId'] as String?,
            ),
          );
        }
        seenEvents = lines.length;
      } finally {
        readingEvents = false;
      }
    }

    final eventPoller = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => unawaited(readEvents()),
    );
    try {
      final exitCode = await _launcher(
        Platform.resolvedExecutable,
        request,
        nonce,
        sha256.convert(payload).toString(),
      );
      eventPoller.cancel();
      while (readingEvents) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      await readEvents();
      if (!await response.exists()) {
        return <String, dynamic>{
          'success': false,
          'message': 'Elevated helper failed with exit code $exitCode.',
        };
      }
      return Map<String, dynamic>.from(
        _decodeValue(jsonDecode(await response.readAsString())) as Map,
      );
    } finally {
      eventPoller.cancel();
      if (await request.exists()) await request.delete();
      if (await response.exists()) await response.delete();
      if (await events.exists()) await events.delete();
    }
  }

  static Future<void> _applyWindowsAcl(Directory directory) async {
    if (!Platform.isWindows) return;
    final domain = Platform.environment['USERDOMAIN'];
    final user = Platform.environment['USERNAME'];
    if (domain == null || user == null) {
      throw StateError('Unable to identify the helper directory owner.');
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
      throw StateError('Unable to secure the elevated helper directory.');
    }
  }

  static Future<int> _launchElevated(
    String executable,
    File request,
    String nonce,
    String digest,
  ) async {
    String quote(String value) => value.replaceAll("'", "''");
    final encodedPath = base64Url.encode(utf8.encode(request.path));
    final script =
        "\$p=Start-Process -FilePath '${quote(executable)}' "
        "-Verb RunAs -PassThru -ArgumentList @("
        "'--zaptweaks-helper','$encodedPath','$nonce','$digest'); "
        r"if(-not $p.WaitForExit(300000)){Stop-Process -Id $p.Id -Force;exit 124}; "
        r'exit $p.ExitCode';
    final encoded = base64.encode(const Utf16Encoder().convert(script));
    final process = await Process.start('powershell.exe', <String>[
      '-NoProfile',
      '-NonInteractive',
      '-EncodedCommand',
      encoded,
    ]);
    try {
      return await process.exitCode.timeout(const Duration(minutes: 6));
    } on TimeoutException {
      process.kill();
      return 124;
    }
  }

  static String _nonce() {
    final random = Random.secure();
    return List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

class ElevatedHelperHost {
  ElevatedHelperHost({
    required Directory allowedDirectory,
    required TweakCatalogService catalogService,
    required TweakManager tweakManager,
    required RestorePointService restorePointService,
    OperationRegistry? operationRegistry,
    OperationContext? operationContext,
    OperationStore? operationStore,
    Future<AppInventoryResult> Function()? systemAppInventory,
  }) : _allowedDirectory = allowedDirectory,
       _catalogService = catalogService,
       _tweakManager = tweakManager,
       _restorePointService = restorePointService,
       _operationRegistry = operationRegistry,
       _operationContext = operationContext,
       _operationStore = operationStore,
       _systemAppInventory = systemAppInventory;

  final Directory _allowedDirectory;
  final TweakCatalogService _catalogService;
  final TweakManager _tweakManager;
  final RestorePointService _restorePointService;
  final OperationRegistry? _operationRegistry;
  final OperationContext? _operationContext;
  final OperationStore? _operationStore;
  final Future<AppInventoryResult> Function()? _systemAppInventory;

  Future<int> run(
    File requestFile,
    String expectedNonce,
    String expectedDigest,
  ) async {
    File? response;
    try {
      final noncePattern = RegExp(r'^[0-9a-f]{64}$');
      final expectedDirectory = _allowedDirectory.absolute.path.toLowerCase();
      final actualDirectory = requestFile.parent.absolute.path.toLowerCase();
      if (actualDirectory != expectedDirectory ||
          !noncePattern.hasMatch(expectedNonce) ||
          requestFile.uri.pathSegments.last != '$expectedNonce.json') {
        throw StateError('Invalid helper request identity.');
      }
      if (!await requestFile.exists() || await requestFile.length() > 4096) {
        throw StateError('Invalid helper request file.');
      }
      final payload = await requestFile.readAsBytes();
      if (sha256.convert(payload).toString() != expectedDigest) {
        throw StateError('Helper request integrity check failed.');
      }
      response = File('${requestFile.path}.response');
      final events = File('${requestFile.path}.events');
      await _writeEvent(events, 'requestAccepted');
      final json = Map<String, dynamic>.from(
        _decodeValue(jsonDecode(utf8.decode(payload))) as Map,
      );
      if (json['nonce'] != expectedNonce) {
        throw StateError('Invalid helper request nonce.');
      }
      if (json['protocol'] == 'appInventory') {
        return await _runSystemAppInventory(json, response, events);
      }
      if (json['protocol'] == 'nativeOperation') {
        return await _runNativeOperation(json, response, events);
      }
      if (json['protocol'] == 'nativePlan') {
        return await _runNativePlan(json, response, events);
      }
      if (json.length != 4 ||
          json['nonce'] != expectedNonce ||
          json['operationId'] is! String ||
          json['desiredValue'] is! bool ||
          json['createRestorePoint'] is! bool) {
        throw StateError('Invalid helper request payload.');
      }
      TweakDescriptor? descriptor;
      for (final candidate in _catalogService.buildCatalog()) {
        if (candidate.id == json['operationId']) {
          descriptor = candidate;
          break;
        }
      }
      if (descriptor == null || !descriptor.isSystemToggle) {
        throw StateError('Operation is not helper-allowlisted.');
      }

      String? restoreMessage;
      if (json['createRestorePoint'] == true) {
        final restore = await _restorePointService.createRestorePoint(
          description: 'ZapTweaks_PreChange',
        );
        if (!restore.success) restoreMessage = restore.message;
      }
      final desired = json['desiredValue'] as bool;
      final applied = await _tweakManager.applyTweak(
        descriptor.systemKey!,
        desired,
      );
      final observed = applied.success
          ? await _tweakManager.detectTweakState(descriptor.systemKey!)
          : null;
      final success = applied.success && observed == desired;
      await _writeAtomic(response, <String, Object?>{
        'success': success,
        'observed': observed,
        if (!success) 'message': applied.errors.join('\n'),
        if (restoreMessage != null) 'restorePointMessage': restoreMessage,
      });
      return success ? 0 : 1;
    } catch (error) {
      if (response != null) {
        await _writeAtomic(response, <String, Object?>{
          'success': false,
          'message': error.toString(),
        });
      }
      return 2;
    }
  }

  Future<int> _runSystemAppInventory(
    Map<String, dynamic> json,
    File response,
    File events,
  ) async {
    if (json.length != 2 || _systemAppInventory == null) {
      throw StateError('Invalid app inventory request.');
    }
    await _writeEvent(events, 'inventoryScanning');
    final result = await _systemAppInventory();
    await _writeAtomic(response, <String, Object?>{
      'success': result.allUsersComplete && result.provisionedComplete,
      'message': result.message,
      'result': <String, Object?>{
        'packages': result.packages
            .map((package) => package.toJson())
            .toList(growable: false),
        'currentUserComplete': result.currentUserComplete,
        'allUsersComplete': result.allUsersComplete,
        'provisionedComplete': result.provisionedComplete,
        'wingetComplete': result.wingetComplete,
        'message': result.message,
      },
    });
    await _writeEvent(events, 'inventoryCompleted');
    return result.allUsersComplete && result.provisionedComplete ? 0 : 1;
  }

  Future<int> _runNativePlan(
    Map<String, dynamic> json,
    File response,
    File events,
  ) async {
    final registry = _operationRegistry;
    final context = _operationContext;
    final rows = json['requests'];
    if (registry == null ||
        context == null ||
        json.length != 5 ||
        json['user'] is! String ||
        json['appVersion'] is! String ||
        rows is! List ||
        rows.isEmpty) {
      throw StateError('Invalid native plan request.');
    }
    final requests = rows
        .map((row) {
          if (row is! Map ||
              row.length != 4 ||
              row['operationId'] is! String ||
              row['parameters'] is! Map) {
            throw StateError('Invalid native plan item.');
          }
          final id = row['operationId']! as String;
          if (!registry.contains(id)) {
            throw StateError('Native operation is not helper-allowlisted.');
          }
          final definition = registry.resolve(id);
          if (definition.id != id ||
              definition.privilege != OperationPrivilege.administrator) {
            throw StateError('Native plan contains a non-elevated operation.');
          }
          return OperationRequest(
            operationId: id,
            target: row['target'] as String?,
            desiredValue: row['desiredValue'],
            parameters: Map<String, Object?>.from(row['parameters']! as Map),
          );
        })
        .toList(growable: false);
    await _writeEvent(events, 'planning');
    final engine = PlanEngine(
      registry: registry,
      context: context,
      user: json['user']! as String,
      appVersion: json['appVersion']! as String,
      store: _operationStore,
      elevatedExecutor: const DirectOperationExecutor(),
    );
    final plan = await engine.plan(requests);
    await _writeEvent(events, 'executingPlan');
    await engine.execute(plan);
    await _writeEvent(events, 'completedPlan');
    await _writeAtomic(response, <String, Object?>{
      'success': true,
      'plan': plan.toJson(),
    });
    return 0;
  }

  Future<int> _runNativeOperation(
    Map<String, dynamic> json,
    File response,
    File events,
  ) async {
    await _writeEvent(events, 'validating');
    final registry = _operationRegistry;
    final context = _operationContext;
    final operationId = json['operationId'];
    if (registry == null ||
        context == null ||
        operationId is! String ||
        !registry.contains(operationId)) {
      throw StateError('Native operation is not helper-allowlisted.');
    }
    final definition = registry.resolve(operationId);
    await _writeEvent(events, 'resolved', operationId: operationId);
    if (definition.id != operationId ||
        definition.privilege != OperationPrivilege.administrator) {
      throw StateError('Native operation cannot run elevated.');
    }
    final parameters = json['parameters'];
    if (parameters is! Map) throw StateError('Invalid native parameters.');
    final request = OperationRequest(
      operationId: operationId,
      target: json['target'] as String?,
      desiredValue: json['desiredValue'],
      parameters: Map<String, Object?>.from(parameters),
    );
    await _writeEvent(events, 'checkingSupport', operationId: operationId);
    final support = await definition.supports(context, request);
    await _writeEvent(events, 'supportChecked', operationId: operationId);
    if (!support.supported) {
      throw StateError(support.reason ?? 'Native operation is unsupported.');
    }

    final action = json['action'];
    late OperationState observed;
    if (action == 'apply' && json.length == 7) {
      await _writeEvent(events, 'applying', operationId: operationId);
      await definition.apply(request);
      await _writeEvent(events, 'verifying', operationId: operationId);
      observed = await definition.verify(request);
      final expected = request.desiredValue == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              OperationStateKind.configured,
              value: request.desiredValue,
            );
      if (!observed.sameValue(expected)) {
        throw StateError('Elevated operation verification failed.');
      }
    } else if (action == 'rollback' &&
        json.length == 8 &&
        json['snapshot'] is Map) {
      final snapshot = OperationSnapshot.fromJson(
        Map<String, Object?>.from(json['snapshot'] as Map),
      );
      await _writeEvent(events, 'rollingBack', operationId: operationId);
      await definition.rollback(request, snapshot);
      await _writeEvent(events, 'verifyingRollback', operationId: operationId);
      observed = await definition.inspect(request);
      if (!observed.sameValue(snapshot.expectedAfterRollback)) {
        throw StateError('Elevated rollback verification failed.');
      }
    } else {
      throw StateError('Invalid native helper action.');
    }
    await _writeEvent(events, 'completed', operationId: operationId);
    await _writeAtomic(response, <String, Object?>{
      'success': true,
      'state': observed.toJson(),
    });
    return 0;
  }

  static Future<void> _writeEvent(
    File file,
    String state, {
    String? operationId,
  }) async {
    file.writeAsStringSync(
      '${jsonEncode(<String, Object?>{'state': state, if (operationId != null) 'operationId': operationId})}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  static Future<void> _writeAtomic(
    File file,
    Map<String, Object?> value,
  ) async {
    final temporary = File('${file.path}.tmp');
    temporary.writeAsStringSync(jsonEncode(_encodeValue(value)), flush: true);
    temporary.renameSync(file.path);
  }
}

Object? _encodeValue(Object? value) {
  if (value is Uint8List) {
    return <String, Object?>{r'$type': 'bytes', 'base64': base64Encode(value)};
  }
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _encodeValue(entry.value),
    };
  }
  if (value is Iterable) return value.map(_encodeValue).toList();
  return value;
}

Object? _decodeValue(Object? value) {
  if (value is Map) {
    if (value[r'$type'] == 'bytes') {
      return base64Decode(value['base64']! as String);
    }
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _decodeValue(entry.value),
    };
  }
  if (value is List) return value.map(_decodeValue).toList();
  return value;
}

class Utf16Encoder {
  const Utf16Encoder();

  List<int> convert(String value) => value.codeUnits
      .expand((unit) => <int>[unit & 0xff, unit >> 8])
      .toList(growable: false);
}
