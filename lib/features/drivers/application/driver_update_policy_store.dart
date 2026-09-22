import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class DriverUpdatePolicyRecord {
  const DriverUpdatePolicyRecord({
    required this.expiresAt,
    required this.previousValue,
  });

  final DateTime? expiresAt;
  final int? previousValue;

  bool get isPermanent => expiresAt == null;

  bool isExpired(DateTime now) =>
      expiresAt != null && !now.isBefore(expiresAt!);

  Map<String, Object?> toJson() => <String, Object?>{
    if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
    'previousValue': previousValue,
  };

  factory DriverUpdatePolicyRecord.fromJson(Map<String, dynamic> json) {
    final expiresAt = json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt']! as String).toUtc();
    final previous = json['previousValue'];
    if (previous != null && previous != 0 && previous != 1) {
      throw const FormatException('Invalid previous driver policy value.');
    }
    return DriverUpdatePolicyRecord(
      expiresAt: expiresAt,
      previousValue: previous as int?,
    );
  }
}

class DriverUpdatePolicyStore {
  DriverUpdatePolicyStore({String? path}) : path = path ?? defaultPath();

  final String path;

  static String defaultPath() => p.join(
    Platform.environment['LOCALAPPDATA'] ?? Directory.current.path,
    'ZapTweaks',
    'driver-update-pause.json',
  );

  Future<DriverUpdatePolicyRecord?> read() async {
    final file = File(path);
    if (!await file.exists()) return null;
    return DriverUpdatePolicyRecord.fromJson(
      Map<String, dynamic>.from(jsonDecode(await file.readAsString()) as Map),
    );
  }

  Future<void> write(DriverUpdatePolicyRecord record) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final temporary = File('$path.tmp');
    await temporary.writeAsString(jsonEncode(record.toJson()), flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(path);
  }

  Future<void> clear() async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
