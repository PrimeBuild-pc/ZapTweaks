import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../application/driver_update_policy_store.dart';

class DriverAssistedPage extends StatelessWidget {
  const DriverAssistedPage({required this.controller, super.key});

  final TweakController controller;

  Future<void> _open(BuildContext context, String target) async {
    final result = target.toLowerCase().endsWith('.msc')
        ? await ProcessRunner.shared.launch('mmc.exe', <String>[target])
        : await ProcessRunner.shared.launch('explorer.exe', <String>[target]);
    if (!result.success && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: Text(AppLocalizations.of(context).operationFailed),
          content: Text(result.details),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final flows =
        <({String title, String description, String target, String action})>[
          (
            title: strings.amdDriverFlow,
            description: strings.amdDriverFlowDescription,
            target: 'https://www.amd.com/en/support/download/drivers.html',
            action: strings.openOfficialSource,
          ),
          (
            title: strings.nvidiaDriverFlow,
            description: strings.nvidiaDriverFlowDescription,
            target: 'https://www.nvidia.com/Download/index.aspx',
            action: strings.openOfficialSource,
          ),
          (
            title: strings.intelDriverFlow,
            description: strings.intelDriverFlowDescription,
            target:
                'https://www.intel.com/content/www/us/en/support/detect.html',
            action: strings.openOfficialSource,
          ),
          (
            title: strings.windowsOptionalDrivers,
            description: strings.windowsOptionalDriversDescription,
            target: 'ms-settings:windowsupdate-optionalupdates',
            action: strings.openWindowsPanel,
          ),
          (
            title: strings.deviceManager,
            description: strings.deviceManagerDescription,
            target: 'devmgmt.msc',
            action: strings.openWindowsPanel,
          ),
        ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: <Widget>[
        _DriverUpdatePolicyCard(controller: controller),
        const SizedBox(height: 12),
        InfoBar(
          title: Text(strings.assistedDriverFlows),
          content: Text(strings.assistedDriverFlowsDescription),
          severity: InfoBarSeverity.info,
        ),
        const SizedBox(height: 12),
        for (final flow in flows) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          flow.title,
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        const SizedBox(height: 4),
                        Text(flow.description),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Button(
                    onPressed: () => _open(context, flow.target),
                    child: Text(flow.action),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _DriverUpdatePolicyCard extends StatefulWidget {
  const _DriverUpdatePolicyCard({required this.controller});

  final TweakController controller;

  @override
  State<_DriverUpdatePolicyCard> createState() =>
      _DriverUpdatePolicyCardState();
}

class _DriverUpdatePolicyCardState extends State<_DriverUpdatePolicyCard> {
  final _store = DriverUpdatePolicyStore();
  DriverUpdatePolicyRecord? _record;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final record = await _store.read();
      if (mounted) setState(() => _record = record);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _execute(OperationRequest request) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[request],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(plan.items.single.error ?? 'Driver policy failed.');
      }
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pause(int days) => _execute(
    OperationRequest(
      operationId: 'toggle_automatic_driver_updates_off',
      desiredValue: 1,
      parameters: <String, Object?>{
        'expiresAt': DateTime.now()
            .toUtc()
            .add(Duration(days: days))
            .toIso8601String(),
      },
    ),
  );

  Future<void> _disablePermanently() => _execute(
    const OperationRequest(
      operationId: 'toggle_automatic_driver_updates_off',
      desiredValue: 1,
      parameters: <String, Object?>{'permanent': true},
    ),
  );

  Future<void> _resume() => _execute(
    OperationRequest(
      operationId: 'toggle_automatic_driver_updates_off',
      desiredValue: _record!.previousValue,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final record = _record;
    final expired = record?.isExpired(DateTime.now().toUtc()) ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.driverUpdatePolicy,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 4),
            Text(strings.driverUpdatePolicyDescription),
            if (record != null) ...<Widget>[
              const SizedBox(height: 8),
              InfoBar(
                title: Text(
                  expired
                      ? strings.driverUpdatePauseExpired
                      : strings.driverUpdatePauseActive,
                ),
                content: Text(
                  record.isPermanent
                      ? strings.driverUpdatePausePermanent
                      : strings.driverUpdatePauseUntil(
                          record.expiresAt!.toLocal().toString(),
                        ),
                ),
                severity: expired
                    ? InfoBarSeverity.warning
                    : InfoBarSeverity.info,
              ),
            ],
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_error!),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: <Widget>[
                Button(
                  onPressed: _busy || record != null ? null : () => _pause(7),
                  child: Text(strings.pauseSevenDays),
                ),
                Button(
                  onPressed: _busy || record != null ? null : () => _pause(30),
                  child: Text(strings.pauseThirtyDays),
                ),
                Button(
                  onPressed: _busy || record != null
                      ? null
                      : _disablePermanently,
                  child: Text(strings.disableUntilRestored),
                ),
                FilledButton(
                  onPressed: _busy || record == null ? null : _resume,
                  child: Text(strings.restoreDriverUpdates),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
