import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/process_runner.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'sparkle_manual_page.dart';

class SparkleHubPage extends StatefulWidget {
  const SparkleHubPage({
    required this.controller,
    required this.category,
    required this.onSafetyPrompt,
    this.initialIndex = 0,
    super.key,
  });

  final TweakController controller;
  final String category;
  final int initialIndex;
  final Future<bool> Function(
    String,
    String, {
    String? confirmLabel,
    String? cancelLabel,
  })
  onSafetyPrompt;

  @override
  State<SparkleHubPage> createState() => _SparkleHubPageState();
}

class _SparkleHubPageState extends State<SparkleHubPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) => SectionTabView(
    currentIndex: _index,
    onChanged: (index) => setState(() => _index = index),
    tabs: [
      Tab(
        text: Text(AppLocalizations.of(context).tweaks),
        icon: const Icon(FluentIcons.rocket),
        body: TweaksPage(
          controller: widget.controller,
          category: widget.category,
          onSafetyPrompt: widget.onSafetyPrompt,
        ),
      ),
      Tab(
        text: Text(AppLocalizations.of(context).manualControls),
        icon: const Icon(FluentIcons.toggle_right),
        body: SparkleManualPage(
          executeRequests: widget.controller.executeNativeRequests,
          openExternal: (uri) async {
            final result = await ProcessRunner.shared.launch('explorer', [
              uri.toString(),
            ]);
            if (!result.success) throw StateError(result.details);
          },
          expertEnabled: widget.controller.expertModeEnabled,
          safeOnly: widget.category == 'Windows',
          advancedOnly: widget.category == 'Expert',
        ),
      ),
    ],
  );
}
