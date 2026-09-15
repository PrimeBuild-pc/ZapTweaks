import 'package:fluent_ui/fluent_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../../tweaks/presentation/pages/tweaks_page.dart';
import 'driver_inventory_page.dart';

class DriversHubPage extends StatefulWidget {
  const DriversHubPage({
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
  State<DriversHubPage> createState() => _DriversHubPageState();
}

class _DriversHubPageState extends State<DriversHubPage> {
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
          text: Text(strings.driverInventory),
          icon: const Icon(FluentIcons.devices3),
          body: DriverInventoryPage(controller: widget.controller),
        ),
        Tab(
          text: Text(strings.driverTools),
          icon: const Icon(FluentIcons.toolbox),
          body: TweaksPage(
            controller: widget.controller,
            category: 'Drivers',
            onSafetyPrompt: widget.onSafetyPrompt,
          ),
        ),
      ],
    );
  }
}
