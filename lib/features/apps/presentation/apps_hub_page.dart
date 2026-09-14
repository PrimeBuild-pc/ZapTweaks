import 'package:fluent_ui/fluent_ui.dart';

import '../../../features/tweaks/application/tweak_controller.dart';
import '../../../features/tweaks/presentation/pages/tweaks_page.dart';
import '../../../l10n/app_localizations.dart';
import 'app_inventory_page.dart';
import 'app_store_page.dart';

class AppsHubPage extends StatefulWidget {
  const AppsHubPage({
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
  State<AppsHubPage> createState() => _AppsHubPageState();
}

class _AppsHubPageState extends State<AppsHubPage> {
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
          text: Text(strings.appStore),
          icon: const Icon(FluentIcons.shop),
          body: const AppStorePage(),
        ),
        Tab(
          text: Text(strings.appManagement),
          icon: const Icon(FluentIcons.apps_content),
          body: const AppInventoryPage(),
        ),
        Tab(
          text: Text(strings.windowsAppTools),
          icon: const Icon(FluentIcons.toolbox),
          body: TweaksPage(
            controller: widget.controller,
            category: 'Apps',
            onSafetyPrompt: widget.onSafetyPrompt,
          ),
        ),
      ],
    );
  }
}
