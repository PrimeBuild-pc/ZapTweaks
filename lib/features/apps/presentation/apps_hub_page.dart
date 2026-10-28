import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';

import '../../../features/tweaks/application/tweak_controller.dart';
import '../../../features/tweaks/presentation/pages/tweaks_page.dart';
import '../../../l10n/app_localizations.dart';
import 'app_inventory_page.dart';
import 'app_store_page.dart';
import 'optional_features_page.dart';
import 'process_list_page.dart';
import 'service_list_page.dart';
import 'startup_apps_page.dart';

class AppsHubPage extends StatefulWidget {
  const AppsHubPage({
    required this.controller,
    required this.onSafetyPrompt,
    this.initialIndex = 0,
    this.initialSearchTerm,
    super.key,
  });

  final TweakController controller;
  final int initialIndex;
  final String? initialSearchTerm;
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
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 6);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SectionTabView(
      currentIndex: _index,
      onChanged: (index) => setState(() => _index = index),
      tabs: <Tab>[
        Tab(
          text: Text(strings.appStore),
          icon: const Icon(FluentIcons.shop),
          body: AppStorePage(
            controller: widget.controller,
            initialQuery: widget.initialSearchTerm,
          ),
        ),
        Tab(
          text: Text(strings.appManagement),
          icon: const Icon(FluentIcons.apps_content),
          body: AppInventoryPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.optionalFeatures),
          icon: const Icon(FluentIcons.processing),
          body: OptionalFeaturesPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.startupApps),
          icon: const Icon(FluentIcons.play),
          body: const StartupAppsPage(),
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
        // New tabs go last so existing initialIndex links keep working.
        Tab(
          text: Text(strings.processesTab),
          icon: const Icon(FluentIcons.task_manager),
          body: const ProcessListPage(),
        ),
        Tab(
          text: Text(strings.servicesTab),
          icon: const Icon(FluentIcons.settings),
          body: ServiceListPage(
            execute: widget.controller.executeNativeRequests,
          ),
        ),
      ],
    );
  }
}
