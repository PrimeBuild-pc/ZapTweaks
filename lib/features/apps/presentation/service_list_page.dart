import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../application/service_inventory.dart';
import '../domain/service_safety_policy.dart';

/// Windows services, Wintoys style: safety class with what stops working,
/// and start-type changes through `service.start.configure` (snapshot,
/// exact rollback) with an undo right after.
class ServiceListPage extends StatefulWidget {
  const ServiceListPage({
    required this.execute,
    this.load,
    this.systemRoot,
    super.key,
  });

  final Future<OperationPlan> Function(List<OperationRequest> requests) execute;
  final Future<List<ServiceEntry>> Function()? load;
  final String? systemRoot;

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

typedef _Undo = ({String service, OperationRequest request});

class _ServiceListPageState extends State<ServiceListPage> {
  List<ServiceEntry> _entries = const <ServiceEntry>[];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _done;
  _Undo? _undo;
  String _search = '';
  ServiceSafety? _safety;
  bool? _microsoft;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _loading = true);
    try {
      final entries =
          await (widget.load ?? () => listServices(ProcessRunner.shared))();
      if (mounted) setState(() => _entries = entries);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ServiceVerdict _verdict(ServiceEntry entry) => classifyService(
    name: entry.name,
    binaryPath: entry.path,
    company: entry.company,
    securityProduct: entry.securityProduct,
    systemRoot:
        widget.systemRoot ??
        Platform.environment['SystemRoot'] ??
        r'C:\Windows',
  );

  static bool _isMicrosoft(ServiceEntry entry) =>
      (entry.company ?? '').toLowerCase().contains('microsoft');

  static OperationRequest _request(String name, int startType, bool delayed) =>
      OperationRequest(
        operationId: 'service.start.configure',
        target: name,
        desiredValue: <String, Object?>{
          'startType': startType,
          'delayedAutoStart': delayed,
        },
      );

  /// Runs one request; null on success, otherwise the error text.
  Future<String?> _run(OperationRequest request) async {
    setState(() {
      _busy = true;
      _error = null;
      _done = null;
    });
    try {
      final plan = await widget.execute(<OperationRequest>[request]);
      final item = plan.items.single;
      if (plan.status == PlanStatus.dryRunComplete ||
          item.status == PlanItemStatus.verified ||
          item.status == PlanItemStatus.pendingRestart) {
        return null;
      }
      return item.error ?? item.status.name;
    } catch (error) {
      return '$error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _change(ServiceEntry entry, int startType) async {
    final strings = AppLocalizations.of(context);
    final to = _startLabel(strings, startType, false);
    final confirmed = await confirmAction(
      context,
      title: strings.serviceChangeTitle(entry.displayName),
      message: strings.serviceChangeConfirm(
        _startLabel(strings, entry.startType, entry.delayed),
        to,
        serviceReasonLabel(strings, _verdict(entry).reason),
      ),
      confirmLabel: _actionLabel(strings, startType),
      destructive: startType == 4,
    );
    if (!confirmed || !mounted) return;
    final error = await _run(_request(entry.name, startType, false));
    if (!mounted) return;
    setState(() {
      _error = error;
      if (error == null) {
        _done = strings.serviceChanged(entry.displayName, to);
        _undo = (
          service: entry.displayName,
          // Windows ships some Manual services with DelayedAutoStart=1
          // (BITS, DoSvc); the flag only acts on Automatic, and a request
          // carrying it with Manual is refused, so it is dropped here.
          request: _request(
            entry.name,
            entry.startType,
            entry.startType == 2 && entry.delayed,
          ),
        );
      }
    });
    await _scan();
  }

  Future<void> _revert() async {
    final undo = _undo;
    if (undo == null) return;
    final error = await _run(undo.request);
    if (!mounted) return;
    setState(() {
      _error = error;
      if (error == null) _undo = null;
    });
    await _scan();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final search = _search.trim().toLowerCase();
    final rows =
        <(ServiceEntry, ServiceVerdict)>[
            for (final entry in _entries) (entry, _verdict(entry)),
          ].where((row) {
            final (entry, verdict) = row;
            return (_safety == null || verdict.safety == _safety) &&
                (_microsoft == null || _isMicrosoft(entry) == _microsoft) &&
                (search.isEmpty ||
                    <String?>[
                      entry.name,
                      entry.displayName,
                      entry.description,
                      entry.company,
                    ].any(
                      (v) => v != null && v.toLowerCase().contains(search),
                    ));
          }).toList()
          ..sort(
            (a, b) => a.$1.displayName.toLowerCase().compareTo(
              b.$1.displayName.toLowerCase(),
            ),
          );
    Widget filter<T>(
      String label,
      T? value,
      Map<T, String> options,
      void Function(T?) onChanged,
    ) => InfoLabel(
      label: label,
      child: ComboBox<T?>(
        value: value,
        placeholder: Text(strings.filterAll),
        items: <ComboBoxItem<T?>>[
          ComboBoxItem<T?>(value: null, child: Text(strings.filterAll)),
          for (final entry in options.entries)
            ComboBoxItem<T?>(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (next) => setState(() => onChanged(next)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 280,
                child: TextBox(
                  placeholder: strings.searchServices,
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              filter<ServiceSafety>(
                strings.filterSafety,
                _safety,
                <ServiceSafety, String>{
                  for (final safety in ServiceSafety.values)
                    safety: _safetyLabel(strings, safety),
                },
                (v) => _safety = v,
              ),
              filter<bool>(strings.filterOrigin, _microsoft, <bool, String>{
                true: strings.originMicrosoft,
                false: strings.processKindThirdParty,
              }, (v) => _microsoft = v),
              Button(
                onPressed: _loading || _busy ? null : _scan,
                child: Text(strings.refreshInventory),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(strings.serviceNote),
          if (_done != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(_done!),
              severity: InfoBarSeverity.success,
              action: _undo == null
                  ? null
                  : Button(
                      onPressed: _busy ? null : _revert,
                      child: Text(strings.serviceUndo),
                    ),
              onClose: () => setState(() {
                _done = null;
                _undo = null;
              }),
            ),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_error!),
              severity: InfoBarSeverity.error,
              onClose: () => setState(() => _error = null),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _loading && _entries.isEmpty
                ? const Center(child: ProgressRing())
                : rows.isEmpty
                ? EmptyState(strings.noServicesMatch)
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) => _ServiceRow(
                      entry: rows[index].$1,
                      verdict: rows[index].$2,
                      microsoft: _isMicrosoft(rows[index].$1),
                      onChange: _busy
                          ? null
                          : (startType) => _change(rows[index].$1, startType),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _safetyLabel(AppLocalizations strings, ServiceSafety safety) =>
    switch (safety) {
      ServiceSafety.canDisable => strings.serviceCanDisable,
      ServiceSafety.dependsOnUse => strings.serviceDependsOnUse,
      ServiceSafety.keep => strings.serviceKeep,
    };

String _startLabel(AppLocalizations strings, int startType, bool delayed) =>
    switch (startType) {
      2 =>
        delayed ? strings.serviceStartDelayed : strings.serviceStartAutomatic,
      3 => strings.serviceStartManual,
      4 => strings.serviceStartDisabled,
      _ => strings.serviceStartBoot,
    };

String _actionLabel(AppLocalizations strings, int startType) =>
    switch (startType) {
      4 => strings.serviceSetDisabled,
      3 => strings.serviceSetManual,
      _ => strings.serviceSetAutomatic,
    };

String serviceReasonLabel(AppLocalizations strings, ServiceReason reason) =>
    switch (reason) {
      ServiceReason.telemetry => strings.svcReasonTelemetry,
      ServiceReason.deviceManagement => strings.svcReasonDeviceManagement,
      ServiceReason.crashReports => strings.svcReasonCrashReports,
      ServiceReason.remoteRegistry => strings.svcReasonRemoteRegistry,
      ServiceReason.offlineMaps => strings.svcReasonOfflineMaps,
      ServiceReason.mediaSharing => strings.svcReasonMediaSharing,
      ServiceReason.retailDemo => strings.svcReasonRetailDemo,
      ServiceReason.xbox => strings.svcReasonXbox,
      ServiceReason.printing => strings.svcReasonPrinting,
      ServiceReason.bluetooth => strings.svcReasonBluetooth,
      ServiceReason.search => strings.svcReasonSearch,
      ServiceReason.sysMain => strings.svcReasonSysMain,
      ServiceReason.touchKeyboard => strings.svcReasonTouchKeyboard,
      ServiceReason.location => strings.svcReasonLocation,
      ServiceReason.biometrics => strings.svcReasonBiometrics,
      ServiceReason.phone => strings.svcReasonPhone,
      ServiceReason.remoteDesktop => strings.svcReasonRemoteDesktop,
      ServiceReason.smartCard => strings.svcReasonSmartCard,
      ServiceReason.parental => strings.svcReasonParental,
      ServiceReason.nfc => strings.svcReasonNfc,
      ServiceReason.hotspot => strings.svcReasonHotspot,
      ServiceReason.scanner => strings.svcReasonScanner,
      ServiceReason.compatibility => strings.svcReasonCompatibility,
      ServiceReason.fax => strings.svcReasonFax,
      ServiceReason.insider => strings.svcReasonInsider,
      ServiceReason.updates => strings.svcReasonUpdates,
      ServiceReason.security => strings.svcReasonSecurity,
      ServiceReason.windowsCore => strings.svcReasonWindowsCore,
      ServiceReason.notReviewed => strings.svcReasonNotReviewed,
      ServiceReason.driverService => strings.svcReasonDriverService,
      ServiceReason.microsoftApp => strings.svcReasonMicrosoftApp,
      ServiceReason.thirdParty => strings.svcReasonThirdParty,
    };

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.entry,
    required this.verdict,
    required this.microsoft,
    required this.onChange,
  });

  final ServiceEntry entry;
  final ServiceVerdict verdict;
  final bool microsoft;
  final ValueChanged<int>? onChange;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final reason = serviceReasonLabel(strings, verdict.reason);
    final tone = switch (verdict.safety) {
      ServiceSafety.canDisable => BadgeTone.positive,
      ServiceSafety.dependsOnUse => BadgeTone.caution,
      // Most services are kept: red on every row would read as an alarm.
      ServiceSafety.keep => BadgeTone.neutral,
    };
    // Only the three SCM start types ZapTweaks can set and restore exactly.
    final changeable =
        verdict.safety != ServiceSafety.keep &&
        const <int>{2, 3, 4}.contains(entry.startType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.displayName,
                  style: theme.typography.bodyStrong,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  <String>[
                    entry.name,
                    if (entry.company != null) entry.company!,
                    if (entry.description != null) entry.description!,
                  ].join(' · '),
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reason,
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: wide ? 170 : 120,
            child: Text(
              _startLabel(strings, entry.startType, entry.delayed),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 110,
            child: StatusBadge(
              entry.running ? strings.serviceRunning : strings.serviceStopped,
              tone: entry.running ? BadgeTone.positive : BadgeTone.neutral,
            ),
          ),
          const SizedBox(width: 8),
          if (wide)
            SizedBox(
              width: 100,
              child: StatusBadge(
                microsoft
                    ? strings.originMicrosoft
                    : strings.processKindThirdParty,
              ),
            ),
          SizedBox(
            width: 140,
            child: StatusBadge(
              _safetyLabel(strings, verdict.safety),
              tone: tone,
              tooltip: reason,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 170,
            child: changeable
                ? DropDownButton(
                    disabled: onChange == null,
                    title: SizedBox(
                      width: 110,
                      child: Text(
                        strings.serviceStartTypeAction,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    items: <MenuFlyoutItemBase>[
                      for (final target in const <int>[4, 3, 2])
                        if (target != entry.startType ||
                            (target == 2 && entry.delayed))
                          MenuFlyoutItem(
                            text: Text(_actionLabel(strings, target)),
                            // Let the flyout close before the dialog opens,
                            // or its barrier stays over the page.
                            onPressed: () =>
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => onChange?.call(target),
                                ),
                          ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
