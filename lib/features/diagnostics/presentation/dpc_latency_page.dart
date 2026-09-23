import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';

class DpcLatencyPage extends StatefulWidget {
  const DpcLatencyPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<DpcLatencyPage> createState() => _DpcLatencyPageState();
}

class _DpcLatencyPageState extends State<DpcLatencyPage> {
  int _duration = 15;
  bool _capturing = false;
  String? _error;
  String? _tracePath;
  Map<String, dynamic>? _report;

  Future<void> _capture() async {
    setState(() {
      _capturing = true;
      _error = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: 'diagnostics.etw.capture',
            desiredValue: true,
            parameters: <String, Object?>{'durationSeconds': _duration},
          ),
        ],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(plan.items.single.error ?? 'ETW capture failed.');
      }
      final path = plan.items.single.written?.message;
      if (path == null || path.isEmpty) {
        throw StateError('The trace path was not returned.');
      }
      final reportFile = File('$path.report.json');
      if (!await reportFile.exists()) {
        throw StateError('The DPC/ISR report was not generated.');
      }
      final report = Map<String, dynamic>.from(
        jsonDecode(await reportFile.readAsString()) as Map,
      );
      if (mounted) {
        setState(() {
          _tracePath = path;
          _report = report;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _openTraceFolder() async {
    final path = _tracePath;
    if (path == null) return;
    final result = await ProcessRunner.shared.launch('explorer.exe', <String>[
      File(path).parent.path,
    ]);
    if (!result.success && mounted) setState(() => _error = result.details);
  }

  int _int(String key) => (_report?[key] as num?)?.toInt() ?? 0;
  double? _double(String key) => (_report?[key] as num?)?.toDouble();

  Map<String, int> _map(String key) {
    final value = _report?[key];
    if (value is! Map) return const <String, int>{};
    return <String, int>{
      for (final entry in value.entries)
        entry.key.toString(): (entry.value as num).toInt(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final modules = _map('topDpcIsrModules');
    final processors = _map('dpcIsrByProcessor');
    final providers = _map('topProviders');
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(
          strings.dpcLatencyAnalyzer,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 6),
        Text(strings.dpcLatencyAnalyzerDescription),
        const SizedBox(height: 12),
        InfoBar(
          title: Text(strings.diagnosticNotCausality),
          content: Text(strings.diagnosticNotCausalityDescription),
          severity: InfoBarSeverity.warning,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 190,
              child: ComboBox<int>(
                value: _duration,
                isExpanded: true,
                items: const <ComboBoxItem<int>>[
                  ComboBoxItem(value: 5, child: Text('5 s')),
                  ComboBoxItem(value: 15, child: Text('15 s')),
                  ComboBoxItem(value: 30, child: Text('30 s')),
                  ComboBoxItem(value: 60, child: Text('60 s')),
                  ComboBoxItem(value: 120, child: Text('120 s')),
                ],
                onChanged: _capturing
                    ? null
                    : (value) => setState(() => _duration = value ?? 15),
              ),
            ),
            FilledButton(
              onPressed: _capturing ? null : _capture,
              child: Text(strings.startDpcCapture),
            ),
            Button(
              onPressed: _tracePath == null ? null : _openTraceFolder,
              child: Text(strings.openTraceFolder),
            ),
          ],
        ),
        if (_capturing) ...<Widget>[
          const SizedBox(height: 12),
          ProgressBar(value: null),
          const SizedBox(height: 4),
          Text(strings.captureInProgress(_duration)),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(
            title: Text(strings.operationFailed),
            content: Text(_error!),
            severity: InfoBarSeverity.error,
          ),
        ],
        if (_report != null) ...<Widget>[
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _metric(
                strings.traceDuration,
                _double('traceDurationSeconds')?.toStringAsFixed(2) ?? '—',
                's',
              ),
              _metric(
                'DPC',
                _int('dpcEvents').toString(),
                _rate('dpcEventsPerSecond'),
              ),
              _metric(
                'ISR',
                _int('isrEvents').toString(),
                _rate('isrEventsPerSecond'),
              ),
              _metric(
                strings.hardFaults,
                _int('hardFaultEvents').toString(),
                '',
              ),
              _metric(
                strings.contextSwitches,
                _int('contextSwitchEvents').toString(),
                '',
              ),
              _metric(strings.totalEvents, _int('totalEvents').toString(), ''),
            ],
          ),
          const SizedBox(height: 18),
          _table(
            strings.kernelModulesObserved,
            modules,
            empty: strings.noKernelModulesObserved,
          ),
          const SizedBox(height: 14),
          _table(
            strings.dpcIsrByProcessor,
            processors,
            empty: strings.noProcessorDistribution,
          ),
          const SizedBox(height: 14),
          _table(
            strings.topEtwProviders,
            providers,
            empty: strings.noProviderData,
          ),
          const SizedBox(height: 12),
          SelectableText(_tracePath!),
        ],
      ],
    );
  }

  String _rate(String key) {
    final value = _double(key);
    return value == null ? '' : '${value.toStringAsFixed(1)}/s';
  }

  Widget _metric(String label, String value, String suffix) => SizedBox(
    width: 170,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$value${suffix.isEmpty ? '' : ' $suffix'}',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );

  Widget _table(
    String title,
    Map<String, int> values, {
    required String empty,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: FluentTheme.of(context).typography.bodyStrong),
          const SizedBox(height: 8),
          if (values.isEmpty)
            Text(empty)
          else
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: <Widget>[
                    Expanded(child: SelectableText(entry.key)),
                    Text(entry.value.toString()),
                  ],
                ),
              ),
        ],
      ),
    ),
  );
}
