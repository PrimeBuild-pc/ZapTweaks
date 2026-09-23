import 'dart:io';
import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/process_runner.dart';
import '../../../platform/windows/power_plan_file_service.dart';
import '../../../platform/windows/power_scheme_service.dart';
import '../../../platform/windows/windows_file_dialog.dart';
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
  List<PowerSettingInfo>? _settings;
  String? _settingsTitle;
  String? _settingsSchemeId;
  String _settingQuery = '';
  String? _settingSubgroup;

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

  Future<void> _showSettings(PowerSchemeInfo scheme) async {
    setState(() => _busy = true);
    try {
      final settings = await Isolate.run(
        () => WindowsPowerSchemeService().enumerateSettings(scheme.id),
      );
      if (mounted) {
        setState(() {
          _settings = settings;
          _settingsTitle = scheme.name;
          _settingsSchemeId = scheme.id;
          _settingQuery = '';
          _settingSubgroup = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _compare(PowerSchemeInfo scheme) async {
    final active = _schemes.singleWhere((item) => item.active);
    setState(() => _busy = true);
    try {
      final results = await Future.wait(<Future<List<PowerSettingInfo>>>[
        Isolate.run(
          () => WindowsPowerSchemeService().enumerateSettings(active.id),
        ),
        Isolate.run(
          () => WindowsPowerSchemeService().enumerateSettings(scheme.id),
        ),
      ]);
      final left = results[0];
      final right = results[1];
      final rightById = <String, PowerSettingInfo>{
        for (final setting in right) setting.settingId: setting,
      };
      final differences = left
          .where((setting) {
            final other = rightById[setting.settingId];
            return other == null ||
                other.value.ac != setting.value.ac ||
                other.value.dc != setting.value.dc;
          })
          .toList(growable: false);
      if (mounted) {
        setState(() {
          _settings = differences;
          _settingsTitle = '${active.name} ↔ ${scheme.name}';
          _settingsSchemeId = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editSetting(PowerSettingInfo setting) async {
    final strings = AppLocalizations.of(context);
    final ac = TextEditingController(text: setting.value.ac.toString());
    final dc = TextEditingController(text: setting.value.dc.toString());
    var selectedAc = setting.value.ac;
    var selectedDc = setting.value.dc;
    final options = <int, String>{
      ...setting.possibleValues,
      if (!setting.possibleValues.containsKey(setting.value.ac))
        setting.value.ac: setting.value.ac.toString(),
      if (!setting.possibleValues.containsKey(setting.value.dc))
        setting.value.dc: setting.value.dc.toString(),
    };
    final values = await showDialog<List<int>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(setting.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.powerSettingRange(
                  setting.minimum?.toString() ?? '?',
                  setting.maximum?.toString() ?? '?',
                  (setting.increment ?? 1).toString(),
                ),
              ),
              if (setting.units?.isNotEmpty == true) Text(setting.units!),
              const SizedBox(height: 12),
              const Text('AC'),
              if (setting.possibleValues.isNotEmpty)
                ComboBox<int>(
                  value: selectedAc,
                  isExpanded: true,
                  items: <ComboBoxItem<int>>[
                    for (final option in options.entries)
                      ComboBoxItem<int>(
                        value: option.key,
                        child: Text('${option.key} — ${option.value}'),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedAc = value ?? selectedAc),
                )
              else
                TextBox(controller: ac),
              const SizedBox(height: 8),
              const Text('DC'),
              if (setting.possibleValues.isNotEmpty)
                ComboBox<int>(
                  value: selectedDc,
                  isExpanded: true,
                  items: <ComboBoxItem<int>>[
                    for (final option in options.entries)
                      ComboBoxItem<int>(
                        value: option.key,
                        child: Text('${option.key} — ${option.value}'),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedDc = value ?? selectedDc),
                )
              else
                TextBox(controller: dc),
            ],
          ),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final parsedAc = setting.possibleValues.isNotEmpty
                    ? selectedAc
                    : int.tryParse(ac.text);
                final parsedDc = setting.possibleValues.isNotEmpty
                    ? selectedDc
                    : int.tryParse(dc.text);
                if (parsedAc != null && parsedDc != null) {
                  Navigator.pop(context, <int>[parsedAc, parsedDc]);
                }
              },
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
    ac.dispose();
    dc.dispose();
    if (values == null || _settingsSchemeId == null) {
      return;
    }
    final minimum = setting.minimum;
    final maximum = setting.maximum;
    final increment = setting.increment ?? 1;
    if (minimum == null ||
        maximum == null ||
        values.any(
          (value) =>
              value < minimum ||
              value > maximum ||
              (increment > 0 && (value - minimum) % increment != 0),
        )) {
      setState(
        () => _error = strings.powerSettingRange(
          minimum?.toString() ?? '?',
          maximum?.toString() ?? '?',
          increment.toString(),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: 'power.setting.configure',
            target: _settingsSchemeId,
            desiredValue: <String, int>{'ac': values[0], 'dc': values[1]},
            parameters: <String, Object?>{
              'subgroupId': setting.subgroupId,
              'settingId': setting.settingId,
            },
          ),
        ],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power setting update failed.',
        );
      }
      final scheme = _schemes.singleWhere(
        (item) => item.id == _settingsSchemeId,
      );
      await _showSettings(scheme);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final path = const WindowsFileDialog().openPowerPlan();
    if (path == null) return;
    final id = Guid.generate().toString().toLowerCase();
    setState(() => _busy = true);
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: 'power.scheme.import',
            desiredValue: id,
            parameters: <String, Object?>{'sourcePath': path},
          ),
        ],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power plan import failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename(PowerSchemeInfo scheme) async {
    final controller = TextEditingController(text: scheme.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(AppLocalizations.of(context).renamePowerPlan),
        content: TextBox(controller: controller, maxLength: 128),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context).rename),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || name.trim() == scheme.name) {
      return;
    }
    setState(() => _busy = true);
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            OperationRequest(
              operationId: 'power.scheme.rename',
              target: scheme.id,
              desiredValue: name.trim(),
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power scheme rename failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _duplicate(PowerSchemeInfo scheme) async {
    final strings = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${scheme.name} - Copy');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.duplicatePowerPlan),
        content: TextBox(controller: controller, maxLength: 128),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(strings.duplicate),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            OperationRequest(
              operationId: 'power.scheme.duplicate',
              target: scheme.id,
              desiredValue: name.trim(),
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power scheme duplication failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(PowerSchemeInfo scheme) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.deletePowerPlan),
        content: Text(strings.deletePowerPlanWarning(scheme.name)),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            OperationRequest(
              operationId: 'power.scheme.delete',
              target: scheme.id,
              desiredValue: null,
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Power scheme deletion failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreDefaults() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.restoreDefaultPowerSchemes),
        content: Text(strings.restoreDefaultPowerSchemesWarning),
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
      _busy = true;
      _error = null;
    });
    try {
      final plan = await widget.controller
          .executeNativeRequests(const <OperationRequest>[
            OperationRequest(
              operationId: 'power.schemes.restore_defaults',
              desiredValue: true,
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Restoring default schemes failed.',
        );
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportActive() async {
    final path = const WindowsFileDialog().savePowerPlan();
    if (path == null) return;
    setState(() => _busy = true);
    try {
      final schemes = WindowsPowerSchemeService();
      await PowerPlanFileService(
        processRunner: ProcessRunner.shared,
        schemes: schemes,
      ).exportScheme(schemes.activeSchemeId, File(path));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatSettingValue(PowerSettingInfo setting, int value) {
    final label = setting.possibleValues[value];
    final units = setting.units?.isNotEmpty == true ? ' ${setting.units}' : '';
    return '$value$units${label == null ? '' : ' ($label)'}';
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
    final subgroups =
        (_settings ?? const <PowerSettingInfo>[])
            .map((setting) => setting.subgroupName)
            .toSet()
            .toList()
          ..sort();
    final visibleSettings = (_settings ?? const <PowerSettingInfo>[])
        .where((setting) {
          final query = _settingQuery.trim().toLowerCase();
          return (_settingSubgroup == null ||
                  setting.subgroupName == _settingSubgroup) &&
              (query.isEmpty ||
                  setting.name.toLowerCase().contains(query) ||
                  setting.description.toLowerCase().contains(query) ||
                  setting.settingId.contains(query) ||
                  setting.subgroupName.toLowerCase().contains(query));
        })
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Row(
          children: <Widget>[
            Button(
              onPressed: _busy ? null : _import,
              child: Text(strings.importPowerPlan),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: _busy || _schemes.isEmpty ? null : _exportActive,
              child: Text(strings.exportActivePowerPlan),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: _busy ? null : _restoreDefaults,
              child: Text(strings.restoreDefaultPowerSchemes),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Button(
                        onPressed: _busy ? null : () => _showSettings(scheme),
                        child: Text(strings.details),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        onPressed: _busy ? null : () => _rename(scheme),
                        child: Text(strings.rename),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        onPressed: _busy ? null : () => _duplicate(scheme),
                        child: Text(strings.duplicate),
                      ),
                      const SizedBox(width: 8),
                      if (!scheme.active) ...<Widget>[
                        Button(
                          onPressed: _busy ? null : () => _compare(scheme),
                          child: Text(strings.compare),
                        ),
                        const SizedBox(width: 8),
                        Button(
                          onPressed: _busy ? null : () => _activate(scheme.id),
                          child: Text(strings.activate),
                        ),
                        const SizedBox(width: 8),
                        Button(
                          onPressed: _busy ? null : () => _delete(scheme),
                          child: Text(strings.delete),
                        ),
                      ] else
                        Text(strings.activePowerPlan),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_settings != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            _settingsTitle!,
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: TextBox(
                  placeholder: strings.searchPowerSettings,
                  onChanged: (value) => setState(() => _settingQuery = value),
                ),
              ),
              SizedBox(
                width: 280,
                child: ComboBox<String?>(
                  value: _settingSubgroup,
                  isExpanded: true,
                  items: <ComboBoxItem<String?>>[
                    ComboBoxItem<String?>(
                      value: null,
                      child: Text(strings.allPowerSubgroups),
                    ),
                    for (final subgroup in subgroups)
                      ComboBoxItem<String?>(
                        value: subgroup,
                        child: Text(subgroup),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _settingSubgroup = value),
                ),
              ),
              Text(strings.powerSettingCount(visibleSettings.length)),
            ],
          ),
          const SizedBox(height: 8),
          if (visibleSettings.isEmpty)
            Text(strings.noPowerDifferences)
          else
            ...visibleSettings.map(
              (setting) => Card(
                child: ListTile(
                  title: Text(setting.name),
                  subtitle: Text(
                    '${setting.subgroupName}\n'
                    'AC ${_formatSettingValue(setting, setting.value.ac)} · '
                    'DC ${_formatSettingValue(setting, setting.value.dc)} · '
                    '${strings.powerSettingRange(setting.minimum?.toString() ?? '?', setting.maximum?.toString() ?? '?', (setting.increment ?? 1).toString())}\n'
                    '${setting.description}\n${setting.settingId}',
                  ),
                  trailing:
                      _settingsSchemeId != null &&
                          setting.minimum != null &&
                          setting.maximum != null
                      ? Button(
                          onPressed: _busy ? null : () => _editSetting(setting),
                          child: Text(strings.edit),
                        )
                      : Tooltip(
                          message: strings.powerSettingBoundsUnavailable,
                          child: const Icon(FluentIcons.lock),
                        ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
