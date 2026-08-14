import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/services/power_plan_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/tweak_controller.dart';

class PowerPlanPicker extends StatefulWidget {
  const PowerPlanPicker({super.key, required this.controller});

  final TweakController controller;

  @override
  State<PowerPlanPicker> createState() => _PowerPlanPickerState();
}

class _PowerPlanPickerState extends State<PowerPlanPicker> {
  late final Future<List<PowerPlan>> _plans = widget.controller
      .availablePowerPlans();
  PowerPlan? _selected;
  bool _busy = false;

  Future<void> _run(Future<dynamic> Function() action) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    displayInfoBar(
      context,
      builder: (_, close) => InfoBar(
        title: Text(
          result.success
              ? AppLocalizations.of(context).done
              : AppLocalizations.of(context).failed,
        ),
        content: Text(result.message ?? ''),
        severity: result.success
            ? InfoBarSeverity.success
            : InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return FutureBuilder<List<PowerPlan>>(
      future: _plans,
      builder: (context, snapshot) {
        final plans = snapshot.data ?? const <PowerPlan>[];
        _selected ??= plans.isEmpty ? null : plans.first;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.powerPlans,
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
                const SizedBox(height: 4),
                Text(strings.powerPlansDescription),
                const SizedBox(height: 10),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const ProgressRing()
                else if (plans.isEmpty)
                  Text(strings.noPowerPlans)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: ComboBox<PowerPlan>(
                          value: _selected,
                          items: <ComboBoxItem<PowerPlan>>[
                            for (final plan in plans)
                              ComboBoxItem<PowerPlan>(
                                value: plan,
                                child: Text(plan.name),
                              ),
                          ],
                          onChanged: _busy
                              ? null
                              : (plan) => setState(() => _selected = plan),
                        ),
                      ),
                      FilledButton(
                        onPressed: _busy || _selected == null
                            ? null
                            : () => _run(
                                () => widget.controller
                                    .importAndActivatePowerPlan(_selected!),
                              ),
                        child: Text(
                          _busy ? strings.working : strings.importAndActivate,
                        ),
                      ),
                      Button(
                        onPressed: _busy
                            ? null
                            : () => _run(
                                widget.controller.restorePreviousPowerPlan,
                              ),
                        child: Text(strings.restorePreviousPlan),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
