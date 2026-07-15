import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';

import 'app_metadata.dart';
import '../core/models/operation_result.dart';
import '../core/services/process_runner.dart';
import '../features/home/presentation/pages/home_stats_page.dart';
import '../features/tweaks/application/tweak_controller.dart';
import '../features/tweaks/presentation/pages/tweaks_page.dart';
import 'app_theme.dart';
import 'settings_page.dart';
import 'widgets/windows_title_bar.dart';

class ZapTweaksApp extends StatefulWidget {
  const ZapTweaksApp({
    super.key,
    required this.controller,
    this.useNativeTitleBar = true,
    this.autoInitializeController = true,
  });

  final TweakController controller;
  final bool useNativeTitleBar;
  final bool autoInitializeController;

  @override
  State<ZapTweaksApp> createState() => _ZapTweaksAppState();
}

class _ZapTweaksAppState extends State<ZapTweaksApp> {
  bool _adminDialogShown = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Color _systemAccentColor = const Color(0xFF0078D4);
  StreamSubscription<dynamic>? _accentSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSystemAccent();
    if (widget.autoInitializeController) {
      widget.controller.initialize();
    }
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _accentSubscription?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  Future<void> _initializeSystemAccent() async {
    try {
      await SystemTheme.accentColor.load();
      final accentColor = SystemTheme.accentColor.accent;
      if (!mounted) {
        return;
      }
      setState(() {
        _systemAccentColor = accentColor;
      });

      _accentSubscription = SystemTheme.onChange.listen((_) async {
        await SystemTheme.accentColor.load();
        if (!mounted) {
          return;
        }
        setState(() {
          _systemAccentColor = SystemTheme.accentColor.accent;
        });
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _systemAccentColor = const Color(0xFF0078D4);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ZapTweaksApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) {
      return;
    }

    if (!widget.controller.isLoading &&
        !widget.controller.isAdmin &&
        !_adminDialogShown) {
      _adminDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showAdminRequiredDialog();
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.controller.categories;
    final settingsPaneIndex = categories.length - 1;
    final selectedCategoryIndex = categories.indexOf(
      widget.controller.selectedCategory,
    );

    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: AppMetadata.productName,
      theme: buildZapTweaksTheme(accentColor: _systemAccentColor),
      navigatorKey: _navigatorKey,
      home: Stack(
        children: <Widget>[
          IgnorePointer(
            ignoring: widget.controller.isInteractionLocked,
            child: NavigationView(
              titleBar: widget.useNativeTitleBar
                  ? WindowsTitleBar(
                      onAboutPressed: _showAboutDialog,
                      backgroundColor: const Color(0xFF1E1E1E),
                    )
                  : _buildFallbackTitleBar(),
              pane: NavigationPane(
                selected:
                    widget.controller.selectedCategory ==
                        TweakController.settingsCategory
                    ? settingsPaneIndex
                    : selectedCategoryIndex,
                onChanged: (index) {
                  if (index == settingsPaneIndex) {
                    widget.controller.selectCategory(
                      TweakController.settingsCategory,
                    );
                  } else if (index >= 0 && index < categories.length - 1) {
                    widget.controller.selectCategory(categories[index]);
                  }
                },
                size: const NavigationPaneSize(openWidth: 240),
                displayMode: PaneDisplayMode.auto,
                items: <NavigationPaneItem>[
                  ...categories
                      .where(
                        (category) =>
                            category != TweakController.settingsCategory,
                      )
                      .map(
                        (category) => PaneItem(
                          icon: Icon(_iconForCategory(category)),
                          title: Text(category),
                          body: _buildCategoryBody(category),
                        ),
                      ),
                  PaneItemSeparator(),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: _buildCategoryBody(TweakController.settingsCategory),
                  ),
                ],
                footerItems: <NavigationPaneItem>[
                  PaneItemAction(
                    icon: _buildUpdatesIcon(),
                    title: Text(
                      widget.controller.isUpdateAvailable
                          ? 'Update available'
                          : 'Updates',
                    ),
                    onTap: _handleUpdatesPressed,
                  ),
                ],
              ),
            ),
          ),
          if (widget.controller.isInteractionLocked)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xAA000000),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const ProgressRing(),
                            const SizedBox(height: 14),
                            Text(
                              widget.controller.interactionLockMessage,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpdatesIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Positioned.fill(child: Icon(FluentIcons.refresh)),
          if (widget.controller.isUpdateAvailable)
            Positioned(
              right: -1,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E1E1E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleUpdatesPressed() async {
    if (widget.controller.isCheckingForUpdates) {
      return;
    }
    if (widget.controller.isUpdateAvailable) {
      await _showAvailableUpdateDialog();
      return;
    }
    await _checkForUpdates();
  }

  Future<void> _checkForUpdates({bool showUpdateDialog = true}) async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }

    showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (_) => const ContentDialog(
        title: Text('Checking for updates'),
        content: Row(
          children: <Widget>[
            ProgressRing(),
            SizedBox(width: 12),
            Expanded(child: Text('Contacting the release server...')),
          ],
        ),
      ),
    );
    final result = await widget.controller.checkForUpdates();
    if (dialogContext.mounted) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
    }
    if (!mounted) {
      return;
    }

    if (result.hasUpdate && showUpdateDialog) {
      await _showAvailableUpdateDialog();
      return;
    }
    if (!result.hasUpdate || !result.success) {
      _showOperationResult(
        OperationResult(success: result.success, message: result.message),
      );
    }
  }

  Future<void> _showAvailableUpdateDialog() async {
    final dialogContext = _navigatorKey.currentContext;
    final update = widget.controller.availableUpdate;
    if (dialogContext == null || update == null) {
      return;
    }

    final action = await showDialog<String>(
      context: dialogContext,
      builder: (context) => ContentDialog(
        title: Text('ZapTweaks ${update.version} is available'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Installed version: ${widget.controller.appVersion}'),
              const SizedBox(height: 12),
              Text(
                update.releaseNotes.isEmpty
                    ? 'Release notes are available on GitHub.'
                    : update.releaseNotes,
                maxLines: 14,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop('later'),
            child: const Text('Later'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop('release'),
            child: const Text('View release'),
          ),
          FilledButton(
            onPressed: update.installerUrl == null
                ? null
                : () => Navigator.of(context).pop('install'),
            child: const Text('Update now'),
          ),
        ],
      ),
    );

    if (action == 'release') {
      await _viewAvailableRelease();
    } else if (action == 'install') {
      await _installAvailableUpdate();
    }
  }

  Future<void> _viewAvailableRelease() async {
    final result = await widget.controller.openAvailableRelease();
    if (!result.success && mounted) {
      _showOperationResult(result);
    }
  }

  Future<void> _installAvailableUpdate() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }

    showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (_) => const ContentDialog(
        title: Text('Downloading update'),
        content: Row(
          children: <Widget>[
            ProgressRing(),
            SizedBox(width: 12),
            Expanded(child: Text('Downloading and preparing the installer...')),
          ],
        ),
      ),
    );
    final result = await widget.controller.installAvailableUpdate();
    if (dialogContext.mounted) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
    }
    if (!mounted) {
      return;
    }

    _showOperationResult(result);
    if (result.success && result.shouldExitApp) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      exit(0);
    }
  }

  void _showOperationResult(OperationResult result) {
    final currentContext = _navigatorKey.currentContext;
    if (currentContext == null) {
      return;
    }
    displayInfoBar(
      currentContext,
      builder: (_, close) => InfoBar(
        title: Text(result.success ? 'Done' : 'Failed'),
        content: Text(result.message ?? ''),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: result.success
            ? InfoBarSeverity.success
            : InfoBarSeverity.error,
      ),
    );
  }

  Widget _buildCategoryBody(String category) {
    if (widget.controller.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ProgressRing(),
            const SizedBox(height: 12),
            Text(widget.controller.loadingStatus),
          ],
        ),
      );
    }

    if (category == 'Home') {
      return _buildHomeStatsPage();
    }

    if (category == TweakController.settingsCategory) {
      return SettingsPage(
        controller: widget.controller,
        onCheckForUpdates: () => _checkForUpdates(showUpdateDialog: false),
        onInstallUpdate: _installAvailableUpdate,
        onViewRelease: _viewAvailableRelease,
      );
    }

    if (!widget.controller.isAdmin) {
      return _buildAdminRequiredView();
    }

    return TweaksPage(
      controller: widget.controller,
      category: category,
      onSafetyPrompt: _showRestorePointDialog,
    );
  }

  Widget _buildHomeStatsPage() {
    return HomeStatsPage(
      hardwareProfile: widget.controller.hardwareProfile,
      latestMetrics: widget.controller.latestMetrics,
      cpuHistory: widget.controller.cpuHistory,
      memoryHistory: widget.controller.memoryHistory,
      gpuHistory: widget.controller.gpuHistory,
      vramHistory: widget.controller.vramHistory,
    );
  }

  Widget _buildFallbackTitleBar() {
    return SizedBox(
      height: 46,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          const Icon(FluentIcons.lightning_bolt, size: 18),
          const SizedBox(width: 8),
          const Text('ZapTweaks'),
          const SizedBox(width: 6),
          const Text(
            'by PrimeBuild',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w100,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(FluentIcons.info),
            onPressed: _showAboutDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAdminRequiredView() {
    return Center(
      child: SizedBox(
        width: 540,
        child: InfoBar(
          title: const Text('Administrator privileges are required'),
          content: const Text(
            'Close the app and launch ZapTweaks with "Run as administrator". '
            'Without elevation, system tweaks cannot be applied safely.',
          ),
          severity: InfoBarSeverity.error,
          isLong: true,
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Gaming':
        return FluentIcons.game;
      case 'Networking':
        return FluentIcons.internet_sharing;
      case 'Power & CPU':
        return FluentIcons.power_button;
      case 'Graphics':
        return FluentIcons.picture;
      case 'Windows':
        return FluentIcons.shield;
      case 'System Checks':
        return FluentIcons.health;
      case 'Refresh & Recovery':
        return FluentIcons.history;
      case 'Setup':
        return FluentIcons.developer_tools;
      case 'Advanced':
        return FluentIcons.warning;
      case 'Privacy':
        return FluentIcons.lock;
      case 'Visuals':
        return FluentIcons.view;
      case 'Tools':
        return FluentIcons.toolbox;
      case TweakController.settingsCategory:
        return FluentIcons.settings;
      case 'Home':
        return FluentIcons.home;
      default:
        return FluentIcons.toolbox;
    }
  }

  Future<bool> _showRestorePointDialog(String title, String message) async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return false;
    }

    final result = await showDialog<bool>(
      context: dialogContext,
      builder: (dialogContext) {
        return ContentDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Create restore point'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showAdminRequiredDialog() {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }

    showDialog<void>(
      context: dialogContext,
      builder: (dialogContext) {
        return ContentDialog(
          title: const Text('Administrator privileges required'),
          content: const Text(
            'ZapTweaks needs administrator permissions to apply system settings.\n\n'
            'Close the app, right-click the executable, and select "Run as administrator".',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }

    showDialog<void>(
      context: dialogContext,
      builder: (dialogContext) {
        return ContentDialog(
          title: const Text('ZapTweaks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Version: v${widget.controller.appVersion}'),
              const SizedBox(height: 6),
              const Text('Author: PrimeBuild'),
              const SizedBox(height: 6),
              const Text(
                'Advanced optimization companion for deeper Windows gaming, hardware, and diagnostics workflows.',
              ),
              const SizedBox(height: 6),
              Text('Year: ${DateTime.now().year}'),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Text('GitHub: '),
                  HyperlinkButton(
                    onPressed: () => ProcessRunner.shared.launch(
                      'explorer',
                      const <String>[AppMetadata.repositoryUrl],
                    ),
                    child: Text(AppMetadata.repositoryUrl),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
