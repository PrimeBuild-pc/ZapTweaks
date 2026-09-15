import 'package:fluent_ui/fluent_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'recovery_page.dart';

class DiagnosticsHubPage extends StatefulWidget {
  const DiagnosticsHubPage({
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
  State<DiagnosticsHubPage> createState() => _DiagnosticsHubPageState();
}

class _DiagnosticsHubPageState extends State<DiagnosticsHubPage> {
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
          text: Text(strings.recovery),
          icon: const Icon(FluentIcons.repair),
          body: RecoveryPage(controller: widget.controller),
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
      ],
    );
  }
}
