import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/power_scheme_service.dart';
import '../../tweaks/application/tweak_controller.dart';

class PowerPlansPage extends StatefulWidget {
  const PowerPlansPage({required this.controller, super.key});
  final TweakController controller;
  @override
  State<PowerPlansPage> createState() => _PowerPlansPageState();
}

class _PowerPlansPageState extends State<PowerPlansPage> {
  List<PowerSchemeInfo> _schemes = const <PowerSchemeInfo>[];
  String _query = '';
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final schemes = WindowsPowerSchemeService().enumerate();
      if (mounted) setState(() => _schemes = schemes);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _activate(String id) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: 'power.scheme.activate',
            desiredValue: id,
          ),
        ],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power scheme activation failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final visible = _schemes
        .where((scheme) {
          final query = _query.trim().toLowerCase();
          return query.isEmpty ||
              scheme.name.toLowerCase().contains(query) ||
              scheme.id.contains(query);
        })
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        TextBox(
          placeholder: strings.searchPowerPlans,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(FluentIcons.search),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(
            title: Text(strings.operationFailed),
            content: Text(_error!),
            severity: InfoBarSeverity.error,
          ),
        ],
        const SizedBox(height: 12),
        if (_busy && _schemes.isEmpty)
          const Center(child: ProgressRing())
        else
          ...visible.map(
            (scheme) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  title: Text(scheme.name),
                  subtitle: Text(scheme.id),
                  leading: Icon(
                    scheme.active
                        ? FluentIcons.radio_btn_on
                        : FluentIcons.radio_btn_off,
                  ),
                  trailing: scheme.active
                      ? Text(strings.activePowerPlan)
                      : Button(
                          onPressed: _busy ? null : () => _activate(scheme.id),
                          child: Text(strings.activate),
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
