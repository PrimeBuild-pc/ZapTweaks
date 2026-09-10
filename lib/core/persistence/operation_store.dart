import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../operations/operation.dart';
import '../plans/operation_plan.dart';

class OperationStore {
  OperationStore(this.database) {
    _migrate();
  }

  final Database database;

  void _migrate() {
    final version = database.userVersion;
    if (version >= 1) return;
    database.execute('BEGIN IMMEDIATE');
    try {
      database.execute('''
        CREATE TABLE plans (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          user_name TEXT NOT NULL,
          app_version TEXT NOT NULL,
          windows_build INTEGER NOT NULL,
          status TEXT NOT NULL,
          restart_required INTEGER NOT NULL DEFAULT 0
        )
      ''');
      database.execute('''
        CREATE TABLE plan_items (
          plan_id TEXT NOT NULL,
          sequence INTEGER NOT NULL,
          operation_id TEXT NOT NULL,
          status TEXT NOT NULL,
          request_json TEXT NOT NULL,
          before_json TEXT NOT NULL,
          written_json TEXT,
          error TEXT,
          PRIMARY KEY (plan_id, sequence),
          FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE
        )
      ''');
      database.execute('''
        CREATE TABLE snapshots (
          plan_id TEXT NOT NULL,
          sequence INTEGER NOT NULL,
          snapshot_json TEXT NOT NULL,
          PRIMARY KEY (plan_id, sequence),
          FOREIGN KEY (plan_id, sequence)
            REFERENCES plan_items(plan_id, sequence) ON DELETE CASCADE
        )
      ''');
      database.execute('''
        CREATE TABLE reboot_continuations (
          plan_id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE
        )
      ''');
      database.execute('''
        CREATE TABLE legacy_mapping (
          legacy_id TEXT PRIMARY KEY,
          operation_id TEXT NOT NULL,
          disposition TEXT NOT NULL
        )
      ''');
      database.userVersion = 1;
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }

  void save(OperationPlan plan) {
    database.execute('BEGIN IMMEDIATE');
    try {
      database.execute(
        '''INSERT OR REPLACE INTO plans
           (id, created_at, user_name, app_version, windows_build, status,
            restart_required) VALUES (?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          plan.id,
          plan.createdAt.toUtc().toIso8601String(),
          plan.user,
          plan.appVersion,
          plan.windowsBuild,
          plan.status.name,
          plan.restartRequired ? 1 : 0,
        ],
      );
      database.execute('DELETE FROM snapshots WHERE plan_id = ?', <Object?>[
        plan.id,
      ]);
      database.execute('DELETE FROM plan_items WHERE plan_id = ?', <Object?>[
        plan.id,
      ]);
      for (var index = 0; index < plan.items.length; index++) {
        final item = plan.items[index];
        database.execute(
          '''INSERT INTO plan_items
             (plan_id, sequence, operation_id, status, request_json,
              before_json, written_json, error)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            plan.id,
            index,
            item.operationId,
            item.status.name,
            _json(<String, Object?>{
              'operationId': item.request.operationId,
              'target': item.request.target,
              'desiredValue': item.request.desiredValue,
              'parameters': item.request.parameters,
            }),
            _json(item.before.toJson()),
            item.written == null ? null : _json(item.written!.toJson()),
            item.error,
          ],
        );
        if (item.snapshot != null) {
          database.execute('INSERT INTO snapshots VALUES (?, ?, ?)', <Object?>[
            plan.id,
            index,
            _json(item.snapshot!.toJson()),
          ]);
        }
      }
      if (plan.restartRequired) {
        database.execute(
          'INSERT OR REPLACE INTO reboot_continuations VALUES (?, ?)',
          <Object?>[plan.id, DateTime.now().toUtc().toIso8601String()],
        );
      } else {
        database.execute(
          'DELETE FROM reboot_continuations WHERE plan_id = ?',
          <Object?>[plan.id],
        );
      }
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }

  List<OperationPlan> loadIncomplete() {
    final rows = database.select(
      "SELECT * FROM plans WHERE status IN ('running', 'failed', "
      "'rollbackRequired', 'interrupted') ORDER BY created_at",
    );
    return rows.map(_readPlan).toList(growable: false);
  }

  OperationPlan? load(String id) {
    final rows = database.select('SELECT * FROM plans WHERE id = ?', <Object?>[
      id,
    ]);
    return rows.isEmpty ? null : _readPlan(rows.single);
  }

  OperationPlan _readPlan(Row row) {
    final id = row['id'] as String;
    final itemRows = database.select(
      '''SELECT i.*, s.snapshot_json
         FROM plan_items i LEFT JOIN snapshots s
           ON s.plan_id = i.plan_id AND s.sequence = i.sequence
         WHERE i.plan_id = ? ORDER BY i.sequence''',
      <Object?>[id],
    );
    final items = itemRows
        .map((itemRow) {
          final requestJson = _decode(itemRow['request_json'] as String);
          final written = itemRow['written_json'] as String?;
          final snapshot = itemRow['snapshot_json'] as String?;
          return PlanItem(
            operationId: itemRow['operation_id'] as String,
            request: OperationRequest(
              operationId: requestJson['operationId']! as String,
              target: requestJson['target'] as String?,
              desiredValue: requestJson['desiredValue'],
              parameters: Map<String, Object?>.from(
                requestJson['parameters']! as Map,
              ),
            ),
            before: OperationState.fromJson(
              _decode(itemRow['before_json'] as String),
            ),
            status: PlanItemStatus.values.byName(itemRow['status'] as String),
            snapshot: snapshot == null
                ? null
                : OperationSnapshot.fromJson(_decode(snapshot)),
            written: written == null
                ? null
                : OperationState.fromJson(_decode(written)),
            error: itemRow['error'] as String?,
          );
        })
        .toList(growable: false);
    return OperationPlan(
      id: id,
      createdAt: DateTime.parse(row['created_at'] as String),
      user: row['user_name'] as String,
      appVersion: row['app_version'] as String,
      windowsBuild: row['windows_build'] as int,
      status: PlanStatus.values.byName(row['status'] as String),
      restartRequired: (row['restart_required'] as int) != 0,
      items: items,
    );
  }

  static String _json(Object? value) => jsonEncode(_encodeValue(value));

  static JsonMap _decode(String value) =>
      Map<String, Object?>.from(_decodeValue(jsonDecode(value)) as Map);

  static Object? _encodeValue(Object? value) {
    if (value is Uint8List) {
      return <String, Object?>{
        r'$type': 'bytes',
        'base64': base64Encode(value),
      };
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

  static Object? _decodeValue(Object? value) {
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
}
