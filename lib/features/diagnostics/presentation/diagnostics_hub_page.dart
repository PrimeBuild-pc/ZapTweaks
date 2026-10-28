import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'app_history_page.dart';
import 'dpc_latency_page.dart';
import 'hardware_monitor_page.dart';
import 'recovery_page.dart';

class DiagnosticsHubPage extends StatefulWidget {
  const DiagnosticsHubPage({
    required this.controller,
    required this.onSafetyPrompt,
    this.initialIndex = 0,
    super.key,
  });

  final TweakController controller;
  final int initialIndex;
  final Future<bool> Function(
    String title,
    String message, {
    String? confirmLabel,
    String? cancelLabel,
  })
  onSafetyPrompt;

  @override
  State<DiagnosticsHubPage> createState() => _DiagnosticsHubPageState();
}

class _DiagnosticsHubPageState extends State<DiagnosticsHubPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SectionTabView(
      currentIndex: _index,
      onChanged: (index) => setState(() => _index = index),
      tabs: <Tab>[
        Tab(
          text: Text(strings.recovery),
          icon: const Icon(FluentIcons.repair),
          body: RecoveryPage(
            controller: widget.controller,
            journal: widget.controller.operationJournal,
          ),
        ),
        Tab(
          text: Text(strings.hardwareMonitor),
          icon: const Icon(FluentIcons.speed_high),
          body: const HardwareMonitorPage(),
        ),
        Tab(
          text: Text(strings.dpcLatencyAnalyzer),
          icon: const Icon(FluentIcons.timer),
          body: DpcLatencyPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.diagnosticTools),
          icon: const Icon(FluentIcons.diagnostic),
          body: TweaksPage(
            controller: widget.controller,
            category: 'Diagnostics & Recovery',
            onSafetyPrompt: widget.onSafetyPrompt,
          ),
        ),
        // Appended: search results open tabs by index.
        Tab(
          text: Text(strings.srumTab),
          icon: const Icon(FluentIcons.history),
          body: const AppHistoryPage(),
        ),
      ],
    );
  }
}
