import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';

import '../../../l10n/app_localizations.dart';
import '../../presets/presentation/presets_page.dart';
import '../../tweaks/application/tweak_controller.dart';
import 'guided_setup_page.dart';

/// Presets first, the step-by-step setup next to them.
class SetupHubPage extends StatefulWidget {
  const SetupHubPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<SetupHubPage> createState() => _SetupHubPageState();
}

class _SetupHubPageState extends State<SetupHubPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SectionTabView(
      currentIndex: _index,
      onChanged: (index) => setState(() => _index = index),
      tabs: <Tab>[
        Tab(
          text: Text(strings.presetsTab),
          icon: const Icon(FluentIcons.favorite_list),
          body: PresetsPage(
            execute: widget.controller.executeNativeRequests,
            inspect: widget.controller.inspectNativeRequests,
            rollback: widget.controller.rollbackAppliedPlan,
          ),
        ),
        Tab(
          text: Text(strings.guidedSetup),
          icon: const Icon(FluentIcons.check_list),
          body: GuidedSetupPage(controller: widget.controller),
        ),
      ],
    );
  }
}
