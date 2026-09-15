import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_theme/system_theme.dart';

import 'app_metadata.dart';
import '../core/models/operation_result.dart';
import '../core/services/app_locale_service.dart';
import '../core/services/process_runner.dart';
import '../l10n/app_localizations.dart';
import '../features/apps/presentation/apps_hub_page.dart';
import '../features/drivers/presentation/drivers_hub_page.dart';
import '../features/home/presentation/pages/home_stats_page.dart';
import '../features/setup/presentation/guided_setup_page.dart';
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
    if (mounted) setState(() {});
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
      locale: AppLocaleService.localeFor(widget.controller.localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildZapTweaksTheme(accentColor: _systemAccentColor),
      navigatorKey: _navigatorKey,
      home: Builder(
        builder: (context) {
          final strings = AppLocalizations.of(context);
          return Stack(
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
                    autoSuggestBox: TextBox(
                      placeholder: strings.searchOperations,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(FluentIcons.search, size: 16),
                      ),
                      onChanged: widget.controller.setSearchQuery,
                    ),
                    autoSuggestBoxReplacement: const Icon(FluentIcons.search),
                    // Headers and separators are filtered out of
                    // NavigationPane.effectiveItems, so they do not shift the
                    // selected index away from `categories`.
                    items: <NavigationPaneItem>[
                      _buildPaneItem(context, categories.first),
                      PaneItemSeparator(),
                      PaneItemHeader(
                        header: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            strings.tweaksSectionHeader,
                            style: FluentTheme.of(
                              context,
                            ).typography.caption?.copyWith(letterSpacing: 0.6),
                          ),
                        ),
                      ),
                      ...categories
                          .skip(1)
                          .where(
                            (category) =>
                                category != TweakController.settingsCategory,
                          )
                          .map((category) => _buildPaneItem(context, category)),
                      PaneItemSeparator(),
                      PaneItem(
                        icon: const Icon(FluentIcons.settings),
                        title: Text(
                          AppLocaleService.category(
                            widget.controller.localeCode,
                            TweakController.settingsCategory,
                          ),
                        ),
                        body: _buildCategoryBody(
                          context,
                          TweakController.settingsCategory,
                        ),
                      ),
                    ],
                    // Only surfaced once a newer release has actually been
                    // detected. Manual checks live in Settings.
                    footerItems: <NavigationPaneItem>[
                      if (widget.controller.isUpdateAvailable)
                        PaneItemAction(
                          icon: _buildUpdatesIcon(),
                          title: Text(strings.updateAvailableShort),
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
          );
        },
      ),
    );
  }

  PaneItem _buildPaneItem(BuildContext paneContext, String category) {
    return PaneItem(
      icon: Icon(_iconForCategory(category)),
      title: Text(
        AppLocaleService.category(widget.controller.localeCode, category),
      ),
      body: _buildCategoryBody(paneContext, category),
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
      builder: (context) {
        final strings = AppLocalizations.of(context);
        return ContentDialog(
          title: Text(strings.checkingForUpdates),
          content: Row(
            children: <Widget>[
              const ProgressRing(),
              const SizedBox(width: 12),
              Expanded(child: Text(strings.contactingReleaseServer)),
            ],
          ),
        );
      },
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
      builder: (context) {
        final strings = AppLocalizations.of(context);
        return ContentDialog(
          title: Text(strings.updateDialogTitle(update.version)),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.installedVersion(widget.controller.appVersion)),
                const SizedBox(height: 12),
                Text(
                  update.releaseNotes.isEmpty
                      ? strings.releaseNotesOnGitHub
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
              child: Text(strings.later),
            ),
            Button(
              onPressed: () => Navigator.of(context).pop('release'),
              child: Text(strings.viewRelease),
            ),
            FilledButton(
              onPressed: update.installerUrl == null
                  ? null
                  : () => Navigator.of(context).pop('install'),
              child: Text(strings.updateNow),
            ),
          ],
        );
      },
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
      builder: (context) {
        final strings = AppLocalizations.of(context);
        return ContentDialog(
          title: Text(strings.downloadingUpdate),
          content: Row(
            children: <Widget>[
              const ProgressRing(),
              const SizedBox(width: 12),
              Expanded(child: Text(strings.downloadingUpdateDescription)),
            ],
          ),
        );
      },
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
    final strings = AppLocalizations.of(currentContext);
    displayInfoBar(
      currentContext,
      builder: (_, close) => InfoBar(
        title: Text(result.success ? strings.done : strings.failed),
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

  Widget _buildCategoryBody(BuildContext context, String category) {
    if (widget.controller.isLoading) {
      return _buildLoadingView(context);
    }

    final strings = AppLocalizations.of(context);
    if (widget.controller.searchQuery.trim().isNotEmpty) {
      return TweaksPage(
        controller: widget.controller,
        category: strings.searchResults,
        descriptors: widget.controller.searchTweaks(
          widget.controller.searchQuery,
        ),
        onSafetyPrompt: _showConfirmDialog,
      );
    }

    if (category == 'Home') {
      return _buildHomeStatsPage();
    }

    if (category == 'Guided Setup') {
      return GuidedSetupPage(controller: widget.controller);
    }

    if (category == 'Apps') {
      return AppsHubPage(
        controller: widget.controller,
        onSafetyPrompt: _showConfirmDialog,
      );
    }

    if (category == 'Drivers') {
      return DriversHubPage(controller: widget.controller);
    }

    if (category == TweakController.settingsCategory) {
      return SettingsPage(
        controller: widget.controller,
        onCheckForUpdates: () => _checkForUpdates(showUpdateDialog: false),
        onInstallUpdate: _installAvailableUpdate,
        onViewRelease: _viewAvailableRelease,
      );
    }

    return TweaksPage(
      controller: widget.controller,
      category: category,
      onSafetyPrompt: _showConfirmDialog,
    );
  }

  /// Startup screen. Listing each step with its own state is what tells the
  /// user the app is working rather than hung on a slow hardware probe.
  Widget _buildLoadingView(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = widget.controller.localeCode;
    final current = widget.controller.loadingStatus;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: ProgressRing(strokeWidth: 3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.startingUp,
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final step in TweakController.loadingSteps)
              _buildLoadingStepRow(
                context,
                label: AppLocaleService.loadingStatus(locale, step),
                done: widget.controller.isLoadingStepDone(step),
                active: step == current,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStepRow(
    BuildContext context, {
    required String label,
    required bool done,
    required bool active,
  }) {
    final theme = FluentTheme.of(context);
    final Widget marker;
    if (done) {
      marker = Icon(FluentIcons.check_mark, size: 12, color: Colors.green);
    } else if (active) {
      marker = const SizedBox(
        width: 12,
        height: 12,
        child: ProgressRing(strokeWidth: 2),
      );
    } else {
      marker = Icon(
        FluentIcons.circle_ring,
        size: 10,
        color: theme.inactiveColor.withValues(alpha: 0.35),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(width: 16, child: Center(child: marker)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: done || active
                  ? theme.typography.body
                  : theme.typography.body?.copyWith(
                      color: theme.inactiveColor.withValues(alpha: 0.45),
                    ),
            ),
          ),
        ],
      ),
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

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Guided Setup':
        return FluentIcons.completed;
      case 'Apps':
        return FluentIcons.app_icon_default;
      case 'Drivers':
        return FluentIcons.devices3;
      case 'Gaming & Performance':
        return FluentIcons.game;
      case 'Windows':
        return FluentIcons.shield;
      case 'Diagnostics & Recovery':
        return FluentIcons.health;
      case 'Expert':
        return FluentIcons.developer_tools;
      case TweakController.settingsCategory:
        return FluentIcons.settings;
      case 'Home':
        return FluentIcons.home;
      default:
        return FluentIcons.toolbox;
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String message, {
    String? confirmLabel,
    String? cancelLabel,
  }) async {
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
              child: Text(
                cancelLabel ?? AppLocalizations.of(dialogContext).cancel,
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                confirmLabel ??
                    AppLocalizations.of(dialogContext).continueAction,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showAboutDialog() {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }

    showDialog<void>(
      context: dialogContext,
      builder: (dialogContext) {
        final strings = AppLocalizations.of(dialogContext);
        return ContentDialog(
          title: const Text('ZapTweaks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(strings.aboutVersion(widget.controller.appVersion)),
              const SizedBox(height: 6),
              Text(strings.author),
              const SizedBox(height: 6),
              Text(strings.aboutDescription),
              const SizedBox(height: 6),
              Text(strings.year(DateTime.now().year)),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  HyperlinkButton(
                    onPressed: () =>
                        _openExternalUrl(AppMetadata.repositoryUrl),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/github.svg',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(strings.github),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: strings.discord,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/discord.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () => _openExternalUrl(AppMetadata.discordUrl),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.close),
            ),
          ],
        );
      },
    );
  }

  void _openExternalUrl(String url) {
    ProcessRunner.shared.launch('explorer', <String>[url]);
  }
}
