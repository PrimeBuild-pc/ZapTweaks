import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/security/elevated_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../domain/windows_optional_feature.dart';

class OptionalFeaturesPage extends StatefulWidget {
  const OptionalFeaturesPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<OptionalFeaturesPage> createState() => _OptionalFeaturesPageState();
}

class _OptionalFeaturesPageState extends State<OptionalFeaturesPage> {
  late final ElevatedHelperClient _helper;
  List<WindowsOptionalFeature> _features = const <WindowsOptionalFeature>[];
  String _query = '';
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _helper = ElevatedHelperClient(directory: defaultElevatedHelperDirectory());
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final features = await _helper.scanOptionalFeatures();
      if (mounted) setState(() => _features = features);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setEnabled(WindowsOptionalFeature feature, bool enabled) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.confirmOptionalFeatureChange),
        content: Text(
          strings.confirmOptionalFeatureChangeMessage(
            feature.name,
            enabled ? strings.enable : strings.disable,
          ),
        ),
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
    setState(() => _loading = true);
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            OperationRequest(
              operationId: 'app.optional_feature.set',
              target: feature.name,
              desiredValue: enabled,
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(plan.items.single.error ?? 'Feature change failed.');
      }
      final written = plan.items.single.written;
      final pending = written?.kind == OperationStateKind.pendingRestart;
      if (!mounted) return;
      setState(() {
        _features = <WindowsOptionalFeature>[
          for (final candidate in _features)
            candidate.name == feature.name
                ? WindowsOptionalFeature(
                    name: candidate.name,
                    state: pending
                        ? (enabled
                              ? WindowsOptionalFeatureState.enablePending
                              : WindowsOptionalFeatureState.disablePending)
                        : (enabled
                              ? WindowsOptionalFeatureState.enabled
                              : WindowsOptionalFeatureState.disabled),
                  )
                : candidate,
        ];
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final features = _features
        .where((feature) => feature.name.toLowerCase().contains(query))
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: TextBox(
                  placeholder: strings.searchOptionalFeatures,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              FilledButton(
                onPressed: _loading ? null : _scan,
                child: Text(strings.scanOptionalFeatures),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(strings.optionalFeaturesUacNotice),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: ProgressRing())
                : ListView.separated(
                    itemCount: features.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      final enabled = feature.enabled;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(feature.name)),
                            Text(switch (feature.state) {
                              WindowsOptionalFeatureState.enabled =>
                                strings.enabled,
                              WindowsOptionalFeatureState.disabled =>
                                strings.disabled,
                              WindowsOptionalFeatureState.enablePending =>
                                strings.enablePending,
                              WindowsOptionalFeatureState.disablePending =>
                                strings.disablePending,
                              WindowsOptionalFeatureState.unknown =>
                                strings.unknown,
                            }),
                            const SizedBox(width: 12),
                            Button(
                              onPressed: enabled == null || _loading
                                  ? null
                                  : () => _setEnabled(feature, !enabled),
                              child: Text(
                                enabled == true
                                    ? strings.disable
                                    : strings.enable,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
