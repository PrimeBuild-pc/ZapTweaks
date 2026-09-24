import 'package:fluent_ui/fluent_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import 'driver_assisted_page.dart';
import 'driver_inventory_page.dart';

class DriversHubPage extends StatefulWidget {
  const DriversHubPage({
    required this.controller,
    this.initialIndex = 0,
    super.key,
  });

  final TweakController controller;
  final int initialIndex;

  @override
  State<DriversHubPage> createState() => _DriversHubPageState();
}

class _DriversHubPageState extends State<DriversHubPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 1);
  }

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
          body: DriverAssistedPage(controller: widget.controller),
        ),
      ],
    );
  }
}
