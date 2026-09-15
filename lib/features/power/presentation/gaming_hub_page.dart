import 'package:fluent_ui/fluent_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'power_plans_page.dart';

class GamingHubPage extends StatefulWidget {
  const GamingHubPage({
    required this.controller,
    required this.onSafetyPrompt,
    super.key,
  });
  final TweakController controller;
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
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TabView(
      currentIndex: _index,
      onChanged: (index) => setState(() => _index = index),
      closeButtonVisibility: CloseButtonVisibilityMode.never,
      tabs: <Tab>[
        Tab(
          text: Text(strings.powerPlans),
          icon: const Icon(FluentIcons.power_button),
          body: PowerPlansPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.tweaks),
          icon: const Icon(FluentIcons.processing),
          body: TweaksPage(
            controller: widget.controller,
            category: 'Gaming & Performance',
            onSafetyPrompt: widget.onSafetyPrompt,
          ),
        ),
      ],
    );
  }
}
