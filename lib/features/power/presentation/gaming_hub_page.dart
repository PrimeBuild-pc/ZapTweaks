import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'game_folder_exclusion_page.dart';
import 'interrupt_configuration_page.dart';
import 'power_plans_page.dart';
import 'tcp_optimizer_page.dart';

class GamingHubPage extends StatefulWidget {
  const GamingHubPage({
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
  State<GamingHubPage> createState() => _GamingHubPageState();
}

class _GamingHubPageState extends State<GamingHubPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        const DefenderExclusionReminder(),
        Expanded(child: _tabs(strings)),
      ],
    );
  }

  Widget _tabs(AppLocalizations strings) {
    return SectionTabView(
      currentIndex: _index,
      onChanged: (index) => setState(() => _index = index),
      tabs: <Tab>[
        Tab(
          text: Text(strings.powerPlans),
          icon: const Icon(FluentIcons.power_button),
          body: PowerPlansPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.interruptConfiguration),
          icon: const Icon(FluentIcons.processing),
          body: InterruptConfigurationPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.tweaks),
          icon: const Icon(FluentIcons.rocket),
          body: TweaksPage(
            controller: widget.controller,
            category: 'Gaming & Performance',
            onSafetyPrompt: widget.onSafetyPrompt,
          ),
        ),
        Tab(
          text: Text(strings.tcpOptimizer),
          icon: const Icon(FluentIcons.network_tower),
          body: TcpOptimizerPage(
            controller: widget.controller,
            journal: widget.controller.operationJournal,
          ),
        ),
        Tab(
          text: Text(strings.gameFolderExclusionTab),
          icon: const Icon(FluentIcons.shield),
          body: GameFolderExclusionPage(controller: widget.controller),
        ),
      ],
    );
  }
}
