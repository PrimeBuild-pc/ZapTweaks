import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  String? _busy;
  String? _message;
  bool _success = false;

  Future<void> _run(String id) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.confirmSystemRepair),
        content: Text(strings.systemRepairWarning),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _busy = id;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(operationId: id, desiredValue: true),
        ],
      );
      _success = plan.status == PlanStatus.completed;
      _message = _success
          ? strings.systemRepairVerified
          : plan.items.single.error ?? strings.operationFailed;
    } catch (error) {
      _success = false;
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        if (_message != null) ...<Widget>[
          InfoBar(
            title: Text(
              _success ? strings.operationCompleted : strings.operationFailed,
            ),
            content: Text(_message!),
            severity: _success
                ? InfoBarSeverity.success
                : InfoBarSeverity.error,
          ),
          const SizedBox(height: 12),
        ],
        _repairCard(
          strings.repairComponentStore,
          strings.repairComponentStoreDescription,
          'recovery.dism.restore_health',
        ),
        const SizedBox(height: 12),
        _repairCard(
          strings.repairSystemFiles,
          strings.repairSystemFilesDescription,
          'recovery.sfc.scan_now',
        ),
      ],
    );
  }

  Widget _repairCard(String title, String description, String id) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _busy == id
              ? const ProgressRing()
              : FilledButton(
                  onPressed: _busy == null ? () => _run(id) : null,
                  child: Text(AppLocalizations.of(context).runRepair),
                ),
        ],
      ),
    ),
  );
}
