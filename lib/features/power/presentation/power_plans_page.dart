import 'dart:io';

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
      final settings = await Future<List<PowerSettingInfo>>(
        () => WindowsPowerSchemeService().enumerateSettings(scheme.id),
      );
      if (mounted) {
        setState(() {
          _settings = settings;
          _settingsTitle = scheme.name;
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
      final service = WindowsPowerSchemeService();
      final left = await Future<List<PowerSettingInfo>>(
        () => service.enumerateSettings(active.id),
      );
      final right = await Future<List<PowerSettingInfo>>(
        () => service.enumerateSettings(scheme.id),
      );
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
        });
      }
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
          if (_settings!.isEmpty)
            Text(strings.noPowerDifferences)
          else
            ..._settings!.map(
              (setting) => ListTile(
                title: Text(setting.name),
                subtitle: Text(
                  '${setting.subgroupName} · AC ${setting.value.ac} · DC ${setting.value.dc}\n${setting.description}',
                ),
              ),
            ),
        ],
      ],
    );
  }
}
