import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/operations/sparkle_operations.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../platform/windows/service_control_manager.dart';
import '../../../platform/windows/sparkle_service_preview.dart';
import 'sparkle_manual_strings.dart';

class SparkleManualPage extends StatefulWidget {
  const SparkleManualPage({
    required this.executeRequests,
    required this.openExternal,
    required this.expertEnabled,
    this.localize,
    this.scanServices,
    this.safeOnly = false,
    this.advancedOnly = false,
    super.key,
  });

  /// Pass controller.executeNativeRequests: user/admin plans remain separate.
  final Future<OperationPlan> Function(List<OperationRequest>) executeRequests;
  final Future<void> Function(Uri) openExternal;
  final bool expertEnabled;
  final bool safeOnly;
  final bool advancedOnly;
  final String Function(String key)? localize;
  final Future<List<SparkleServicePreview>> Function()? scanServices;

  @override
  State<SparkleManualPage> createState() => _SparkleManualPageState();
}

class _SparkleManualPageState extends State<SparkleManualPage> {
  final Set<String> _selected = <String>{};
  final TextEditingController _delay = TextEditingController(text: '0');
  final Map<String, int> _serviceSelection = <String, int>{};
  List<SparkleServicePreview> _services = const <SparkleServicePreview>[];
  bool _busy = false;
  bool _loading = false;
  String? _message;
  bool _success = false;

  String _text(String key) {
    if (widget.localize != null) return widget.localize!(key);
    final italian = Localizations.localeOf(context).languageCode == 'it';
    return (italian ? sparkleManualItalian : sparkleManualEnglish)[key] ?? key;
  }

  @override
  void dispose() {
    _delay.dispose();
    super.dispose();
  }

  List<OperationRequest> get _safeRequests => <OperationRequest>[
    if (_selected.contains('sparkleClock')) ...const <OperationRequest>[
      OperationRequest(
        operationId: 'sparkle.clock.short_time',
        desiredValue: 'HH:mm',
      ),
      OperationRequest(
        operationId: 'sparkle.clock.time_format',
        desiredValue: 'HH:mm:ss',
      ),
    ],
    if (_selected.contains('sparkleSeconds'))
      const OperationRequest(
        operationId: 'sparkle.shell.seconds',
        desiredValue: 1,
      ),
    if (_selected.contains('sparkleMenuDelay'))
      OperationRequest(
        operationId: 'sparkle.shell.menu_delay',
        desiredValue: _delay.text,
      ),
    if (_selected.contains('sparkleLockScreen')) ...const <OperationRequest>[
      OperationRequest(operationId: 'sparkle.privacy.overlay', desiredValue: 0),
      OperationRequest(
        operationId: 'sparkle.privacy.lock_screen',
        desiredValue: 0,
      ),
    ],
    if (_selected.contains('sparkleSearch'))
      const OperationRequest(
        operationId: 'sparkle.shell.hide_search',
        desiredValue: 0,
      ),
  ];

  bool get _validDelay =>
      !_selected.contains('sparkleMenuDelay') ||
      (RegExp(r'^(0|[1-9][0-9]{0,3})$').hasMatch(_delay.text) &&
          int.parse(_delay.text) <= 4000);

  Future<void> _preview(
    List<OperationRequest> requests, {
    String? warningKey,
    bool expert = false,
  }) async {
    if (_busy || requests.isEmpty || (expert && !widget.expertEnabled)) return;
    // Keep all controls locked while the preview is open as well as executing.
    setState(() {
      _busy = true;
      _message = null;
      _success = false;
    });
    try {
      var consent = !expert;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, updateDialog) => ContentDialog(
            title: Text(_text('sparklePreview')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_text(warningKey ?? 'sparkleManualSafeNotice')),
                  const SizedBox(height: 12),
                  for (final request in requests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${request.operationId}${request.target == null ? '' : ' / ${request.target}'} → ${request.desiredValue}',
                      ),
                    ),
                  if (expert)
                    Checkbox(
                      checked: consent,
                      content: Expanded(
                        child: Text(_text('sparkleExpertConsent')),
                      ),
                      onChanged: (value) =>
                          updateDialog(() => consent = value == true),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_text('sparkleCancel')),
              ),
              FilledButton(
                onPressed: !consent || (expert && !widget.expertEnabled)
                    ? null
                    : () => Navigator.pop(context, true),
                child: Text(_text('sparkleApply')),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true || !mounted || (expert && !widget.expertEnabled)) {
        return;
      }
      setState(() => _loading = true);
      final plan = await widget.executeRequests(requests);
      if (!mounted) return;
      if (plan.status == PlanStatus.dryRunComplete) {
        setState(() {
          _success = true;
          _message = _text('sparkleDryRun');
        });
      } else if (plan.status == PlanStatus.completed &&
          plan.items.length == requests.length &&
          plan.items.every(
            (item) =>
                item.status == PlanItemStatus.verified ||
                (item.status == PlanItemStatus.skipped && item.error == null) ||
                item.status == PlanItemStatus.pendingRestart,
          )) {
        setState(() {
          _success = true;
          _message = _text('sparkleDone');
          if (requests.any(
            (request) => request.operationId == 'service.start.configure',
          )) {
            _services = const <SparkleServicePreview>[];
            _serviceSelection.clear();
          }
        });
      } else {
        throw StateError(
          [
            _text('sparkleFailed'),
            for (final item in plan.items)
              '${item.operationId}${item.request.target == null ? '' : ' / ${item.request.target}'}: ${item.status.name}${item.error == null ? '' : ' · ${item.error}'}',
          ].join('\n'),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _success = false;
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _scanServices() async {
    setState(() {
      _busy = true;
      _loading = true;
      _message = null;
      _success = false;
    });
    try {
      final previews =
          await (widget.scanServices?.call() ??
              Future<List<SparkleServicePreview>>.sync(
                () => inspectSparkleServices(const ServiceControlManager()),
              ));
      if (mounted) {
        setState(() {
          _services = previews;
          _serviceSelection.clear();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _success = false;
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _openSource() async {
    try {
      await widget.openExternal(Uri.parse(sparkleSourceUrl));
    } catch (error) {
      if (mounted) {
        setState(() {
          _success = false;
          _message = error.toString();
        });
      }
    }
  }

  Widget _heading(String key) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(_text(key), style: FluentTheme.of(context).typography.subtitle),
  );

  Widget _choice(String key) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Checkbox(
      key: ValueKey(key),
      checked: _selected.contains(key),
      content: Expanded(child: Text(_text(key))),
      onChanged: _busy
          ? null
          : (value) => setState(() {
              if (value == true) {
                _selected.add(key);
              } else {
                _selected.remove(key);
              }
            }),
    ),
  );

  Widget _expertAction(String title, String warning, String operationId) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_text(warning)),
            const SizedBox(height: 8),
            Button(
              key: ValueKey(operationId),
              onPressed: _busy
                  ? null
                  : () => _preview(
                      <OperationRequest>[
                        OperationRequest(
                          operationId: operationId,
                          desiredValue:
                              operationId ==
                                  'sparkle.security.rdp_warning_version'
                              ? 1
                              : 0,
                        ),
                      ],
                      warningKey: warning,
                      expert: true,
                    ),
              child: Text(_text(title)),
            ),
          ],
        ),
      );

  Widget _serviceTile(SparkleServicePreview preview) {
    final service = preview.service;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            preview.name,
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
          if (service == null)
            Text(preview.error ?? _text('sparkleUnavailable')),
          if (service != null) ...<Widget>[
            Text(
              '${_text('sparkleServiceCurrent')}: ${service.startType} / ${service.delayedAutoStart} / ${service.state}',
            ),
            Text(
              '${_text('sparkleServiceDependencies')}: ${service.dependencies.join(', ')}',
            ),
            Text(
              '${_text('sparkleServiceDependents')}: ${service.dependents.join(', ')}',
            ),
            const SizedBox(height: 8),
            ComboBox<int>(
              key: ValueKey('service:${preview.name}'),
              placeholder: Text(_text('sparkleServiceChoice')),
              value: _serviceSelection[preview.name],
              isExpanded: true,
              items: <ComboBoxItem<int>>[
                ComboBoxItem(
                  value: 0,
                  child: Text(_text('sparkleServiceUnchanged')),
                ),
                ComboBoxItem(
                  value: 2,
                  child: Text(_text('sparkleServiceAutomatic')),
                ),
                ComboBoxItem(
                  value: 3,
                  child: Text(_text('sparkleServiceManual')),
                ),
                ComboBoxItem(
                  value: 4,
                  child: Text(_text('sparkleServiceDisabled')),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() {
                      if (value == null || value == 0) {
                        _serviceSelection.remove(preview.name);
                      } else {
                        _serviceSelection[preview.name] = value;
                      }
                    }),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: <Widget>[
      Text(
        _text('sparkleManualTitle'),
        style: FluentTheme.of(context).typography.title,
      ),
      const SizedBox(height: 8),
      Text(_text('sparkleManualIntro')),
      const SizedBox(height: 8),
      Button(onPressed: _openSource, child: Text(_text('sparkleExternal'))),
      if (_loading) ...<Widget>[
        const SizedBox(height: 12),
        const ProgressBar(),
      ],
      if (_message != null) ...<Widget>[
        const SizedBox(height: 12),
        InfoBar(
          title: Text(_message!),
          severity: _success ? InfoBarSeverity.success : InfoBarSeverity.error,
        ),
      ],
      if (!widget.advancedOnly) ...<Widget>[
        _heading('sparkleManualSafe'),
        Text(_text('sparkleManualSafeNotice')),
        _choice('sparkleClock'),
        _choice('sparkleSeconds'),
        _choice('sparkleMenuDelay'),
        SizedBox(
          width: 240,
          child: Semantics(
            label: _text('sparkleMenuDelay'),
            child: TextBox(
              key: const ValueKey('sparkleMenuDelayInput'),
              controller: _delay,
              enabled: !_busy && _selected.contains('sparkleMenuDelay'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        _choice('sparkleLockScreen'),
        _choice('sparkleSearch'),
        Button(
          key: const ValueKey('sparkleSafePreview'),
          onPressed: _busy || _selected.isEmpty || !_validDelay
              ? null
              : () => _preview(_safeRequests),
          child: Text(_text('sparklePreview')),
        ),
      ],
      if (!widget.safeOnly) ...<Widget>[
        _heading('sparkleExpert'),
        if (!widget.expertEnabled)
          InfoBar(
            title: Text(_text('sparkleExpertLocked')),
            severity: InfoBarSeverity.warning,
          )
        else ...<Widget>[
          _expertAction(
            'sparkleHvci',
            'sparkleHvciWarning',
            'sparkle.security.hvci_configured_off',
          ),
          _expertAction(
            'sparkleRdp',
            'sparkleRdpWarning',
            'sparkle.security.rdp_warning_version',
          ),
          _heading('sparkleServices'),
          Text(_text('sparkleServicesWarning')),
          const SizedBox(height: 8),
          Button(
            onPressed: _busy ? null : _scanServices,
            child: Text(_text('sparkleScanServices')),
          ),
          ..._services.map(_serviceTile),
          Button(
            key: const ValueKey('sparkleServicePreview'),
            onPressed: _busy || _serviceSelection.isEmpty
                ? null
                : () => _preview(
                    sparkleServiceRequests(_serviceSelection),
                    expert: true,
                    warningKey: 'sparkleServicesWarning',
                  ),
            child: Text(_text('sparklePreview')),
          ),
        ],
        _heading('sparkleUnavailable'),
        for (final name in <String>[
          'sparkleDefender',
          'sparkleEdge',
          'sparkleNvidia',
        ]) ...<Widget>[
          _heading(name),
          Text(_text('${name}Unavailable')),
          const SizedBox(height: 8),
          Button(onPressed: _openSource, child: Text(_text('sparkleExternal'))),
        ],
      ],
    ],
  );
}
