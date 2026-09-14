import '../operations/operation.dart';

enum PlanStatus {
  planned,
  running,
  dryRunComplete,
  completed,
  failed,
  rollbackRequired,
  rolledBack,
  rollbackConflict,
  interrupted,
}

enum PlanItemStatus {
  planned,
  snapshotted,
  skipped,
  applying,
  verified,
  pendingRestart,
  failed,
  rolledBack,
  rollbackConflict,
}

class PlanItem {
  PlanItem({
    required this.operationId,
    required this.request,
    required this.before,
    this.status = PlanItemStatus.planned,
    this.snapshot,
    this.written,
    this.error,
  });

  final String operationId;
  final OperationRequest request;
  final OperationState before;
  PlanItemStatus status;
  OperationSnapshot? snapshot;
  OperationState? written;
  String? error;

  JsonMap toJson() => <String, Object?>{
    'operationId': operationId,
    'request': <String, Object?>{
      'operationId': request.operationId,
      'target': request.target,
      'desiredValue': request.desiredValue,
      'parameters': request.parameters,
    },
    'before': before.toJson(),
    'status': status.name,
    if (snapshot != null) 'snapshot': snapshot!.toJson(),
    if (written != null) 'written': written!.toJson(),
    if (error != null) 'error': error,
  };

  factory PlanItem.fromJson(JsonMap json) {
    final request = Map<String, Object?>.from(json['request']! as Map);
    return PlanItem(
      operationId: json['operationId']! as String,
      request: OperationRequest(
        operationId: request['operationId']! as String,
        target: request['target'] as String?,
        desiredValue: request['desiredValue'],
        parameters: Map<String, Object?>.from(request['parameters']! as Map),
      ),
      before: OperationState.fromJson(
        Map<String, Object?>.from(json['before']! as Map),
      ),
      status: PlanItemStatus.values.byName(json['status']! as String),
      snapshot: json['snapshot'] == null
          ? null
          : OperationSnapshot.fromJson(
              Map<String, Object?>.from(json['snapshot']! as Map),
            ),
      written: json['written'] == null
          ? null
          : OperationState.fromJson(
              Map<String, Object?>.from(json['written']! as Map),
            ),
      error: json['error'] as String?,
    );
  }
}

class OperationPlan {
  OperationPlan({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.appVersion,
    required this.windowsBuild,
    required this.items,
    this.status = PlanStatus.planned,
    this.restartRequired = false,
  });

  final String id;
  final DateTime createdAt;
  final String user;
  final String appVersion;
  final int windowsBuild;
  final List<PlanItem> items;
  PlanStatus status;
  bool restartRequired;

  JsonMap toJson() => <String, Object?>{
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'user': user,
    'appVersion': appVersion,
    'windowsBuild': windowsBuild,
    'status': status.name,
    'restartRequired': restartRequired,
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory OperationPlan.fromJson(JsonMap json) => OperationPlan(
    id: json['id']! as String,
    createdAt: DateTime.parse(json['createdAt']! as String).toUtc(),
    user: json['user']! as String,
    appVersion: json['appVersion']! as String,
    windowsBuild: json['windowsBuild']! as int,
    status: PlanStatus.values.byName(json['status']! as String),
    restartRequired: json['restartRequired']! as bool,
    items: (json['items']! as List)
        .map(
          (item) => PlanItem.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList(growable: false),
  );
}
