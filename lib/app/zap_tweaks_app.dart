import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_metadata.dart';
import '../features/home/presentation/pages/home_stats_page.dart';
import '../features/tweaks/application/tweak_controller.dart';
import '../features/tweaks/presentation/pages/tweaks_page.dart';
import 'app_theme.dart';
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
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: AppMetadata.productName,
      theme: buildZapTweaksTheme(accentColor: _systemAccentColor),
      navigatorKey: _navigatorKey,
      home: NavigationView(
        titleBar: widget.useNativeTitleBar
            ? WindowsTitleBar(
                onAboutPressed: _showAboutDialog,
                backgroundColor: const Color(0xFF1E1E1E),
              )
            : _buildFallbackTitleBar(),
        pane: NavigationPane(
          selected: widget.controller.categories.indexOf(
            widget.controller.selectedCategory,
          ),
          onChanged: (index) {
            if (index >= 0 && index < widget.controller.categories.length) {
              widget.controller.selectCategory(
                widget.controller.categories[index],
              );
            }
          },
          size: const NavigationPaneSize(openWidth: 240),
          displayMode: PaneDisplayMode.auto,
          items: widget.controller.categories
              .map(
                (category) => PaneItem(
                  icon: Icon(_iconForCategory(category)),
                  title: Text(category),
                  body: _buildCategoryBody(category),
                ),
              )
              .toList(),
          footerItems: <NavigationPaneItem>[
            PaneItemHeader(
              header: Row(
                children: <Widget>[
                  const Icon(FluentIcons.shield, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.controller.isDryRunMode
                          ? 'Execution: Dry-Run'
                          : 'Execution: Production',
                    ),
                  ),
                  ToggleSwitch(
                    checked: widget.controller.isDryRunMode,
                    onChanged: (next) async {
                      await widget.controller.setDryRunMode(next);
                    },
                  ),
                ],
              ),
            ),
            PaneItemAction(
              icon: const Icon(FluentIcons.refresh),
              title: const Text('Check updates'),
              onTap: () async {
                final appContext = context;
                final checkingDialogContext = _navigatorKey.currentContext;
                if (checkingDialogContext != null) {
                  showDialog<void>(
                    context: checkingDialogContext,
                    barrierDismissible: false,
                    builder: (_) => const ContentDialog(
                      title: Text('Checking for updates'),
                      content: Text(
                        'Contacting release server and validating version...',
                      ),
                    ),
                  );
                }

                final result = await widget.controller.checkForUpdates();

                if (checkingDialogContext != null &&
                    checkingDialogContext.mounted) {
                  final rootNavigator = Navigator.of(
                    checkingDialogContext,
                    rootNavigator: true,
                  );
                  if (rootNavigator.canPop()) {
                    rootNavigator.pop();
                  }
                }

                if (!appContext.mounted) {
                  return;
                }

                if (result.shouldExitApp && result.success) {
                  displayInfoBar(
                    appContext,
                    builder: (_, close) => InfoBar(
                      title: const Text('Updating'),
                      content: Text(result.message ?? 'Launching installer...'),
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                      severity: InfoBarSeverity.warning,
                    ),
                  );
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  exit(0);
                }

                displayInfoBar(
                  appContext,
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
              },
            ),
          ],
        ),
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
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.controller.latestMetricsListenable,
        widget.controller.cpuHistoryListenable,
        widget.controller.memoryHistoryListenable,
      ]),
      builder: (_, child) {
        return HomeStatsPage(
          hardwareProfile: widget.controller.hardwareProfile,
          latestMetrics: widget.controller.latestMetricsListenable.value,
          cpuHistory: widget.controller.cpuHistoryListenable.value,
          memoryHistory: widget.controller.memoryHistoryListenable.value,
        );
      },
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
          Text(
            'by PrimeBuild',
            style: FluentTheme.of(context).typography.caption?.copyWith(
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
        return FluentIcons.home;
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
              Text('Current Version: v${widget.controller.appVersion}'),
              const SizedBox(height: 6),
              const Text('Author: PrimeBuild'),
              const SizedBox(height: 6),
              Text(
                'Date: ${DateTime.now().toIso8601String().split('T').first}',
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Text('License: '),
                  HyperlinkButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(AppMetadata.repositoryUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text('Repository'),
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
