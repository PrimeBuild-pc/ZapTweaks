import 'package:flutter/foundation.dart';

import '../../../core/operations/operation.dart';
import '../domain/app_package.dart';
import 'uninstall_command.dart';

enum QueueStatus { waiting, running, done, failed, skipped }

class QueueItem {
  QueueItem(this.app, this.plan)
    : status = plan is UninstallManual
          ? QueueStatus.skipped
          : QueueStatus.waiting;

  final AppPackage app;

  /// Preview only: the operation re-reads the registry before running.
  final UninstallPlan plan;
  QueueStatus status;
  String? message;

  bool get silent =>
      plan is UninstallCommand && (plan as UninstallCommand).silent;

  /// Registry text of a manual step, shown to the user, never executed.
  String? get manualCommandLine => switch (plan) {
    UninstallManual(:final commandLine) => commandLine,
    UninstallCommand() => null,
  };

  OperationRequest get request => OperationRequest(
    operationId: app.uninstall!.hive == 'HKCU'
        ? 'app.win32.uninstall_user'
        : 'app.win32.uninstall',
    target: app.packageId,
    desiredValue: false,
    parameters: <String, Object?>{'silent': silent},
  );
}

/// Uninstalls run strictly one at a time. Programs that open a window go
/// first, while the user is watching; silent ones follow unattended.
class UninstallQueue extends ChangeNotifier {
  UninstallQueue(List<QueueItem> items)
    : items = <QueueItem>[
        ...items.where((i) => i.status == QueueStatus.waiting && !i.silent),
        ...items.where((i) => i.status == QueueStatus.waiting && i.silent),
        ...items.where((i) => i.status != QueueStatus.waiting),
      ];

  factory UninstallQueue.build(
    Iterable<AppPackage> apps, {
    required Map<String, String> environment,
    required bool Function(String path) fileExists,
  }) => UninstallQueue(<QueueItem>[
    for (final app in apps.where((app) => app.uninstall != null))
      QueueItem(
        app,
        planUninstall(
          app.uninstall!,
          environment: environment,
          fileExists: fileExists,
        ),
      ),
  ]);

  final List<QueueItem> items;
  bool _stopped = false;
  bool get running => items.any((i) => i.status == QueueStatus.running);

  void skip(int index) {
    if (items[index].status != QueueStatus.waiting) return;
    items[index].status = QueueStatus.skipped;
    notifyListeners();
  }

  /// Lets the current uninstaller finish, then skips the rest.
  void stop() {
    _stopped = true;
    notifyListeners();
  }

  /// [execute] returns null on success or the failure message.
  Future<void> run(Future<String?> Function(QueueItem item) execute) async {
    for (final item in items) {
      if (item.status != QueueStatus.waiting) continue;
      if (_stopped) {
        item.status = QueueStatus.skipped;
        continue;
      }
      item.status = QueueStatus.running;
      notifyListeners();
      try {
        item.message = await execute(item);
      } catch (error) {
        item.message = error.toString();
      }
      item.status = item.message == null
          ? QueueStatus.done
          : QueueStatus.failed;
      notifyListeners();
    }
    notifyListeners();
  }
}
