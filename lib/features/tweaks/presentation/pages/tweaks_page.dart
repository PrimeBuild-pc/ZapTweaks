import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/models/tweak_descriptor.dart';
import '../../../../core/services/tweak_text_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/action_tweaks.dart';
import '../../application/tweak_controller.dart';
import '../widgets/power_plan_picker.dart';
import '../widgets/tweak_switch_tile.dart';

class TweaksPage extends StatefulWidget {
  const TweaksPage({
    super.key,
    required this.controller,
    required this.category,
    required this.onSafetyPrompt,
    this.descriptors,
  });

  final TweakController controller;
  final String category;
  final List<TweakDescriptor>? descriptors;
  final Future<bool> Function(
    String title,
    String message, {
    String? confirmLabel,
    String? cancelLabel,
  })
  onSafetyPrompt;

  static const Set<String> _networkReconnectHintToggleIds = <String>{
    'network_ecn_disabled',
    'network_timestamps_disabled',
    'network_rss_enabled',
  };

  @override
  State<TweaksPage> createState() => _TweaksPageState();
}

class _TweaksPageState extends State<TweaksPage> {
  bool _bannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final tweaks =
        widget.descriptors ?? widget.controller.categoryTweaks(widget.category);
    final availableTweaks = tweaks
        .where(widget.controller.isDescriptorAvailable)
        .toList(growable: false);

    if (availableTweaks.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).noTweaksAvailable),
      );
    }

    final strings = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (widget.category == 'Gaming & Performance') ...<Widget>[
          PowerPlanPicker(controller: widget.controller),
          const SizedBox(height: 12),
        ],
        if (widget.controller.needsRestart && !_bannerDismissed)
          InfoBar(
            title: Text(strings.restartRequired),
            content: Text(strings.restartRequiredDescription),
            severity: InfoBarSeverity.warning,
            isLong: true,
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Button(
                  child: Text(strings.restartNow),
                  onPressed: () async {
                    await widget.controller.restartSystem();
                    if (!mounted) {
                      return;
                    }

                    setState(() => _bannerDismissed = false);
                  },
                ),
                const SizedBox(width: 8),
                Button(
                  child: Text(strings.later),
                  onPressed: () {
                    setState(() => _bannerDismissed = true);
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (widget.category == 'Tools')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InfoBar(
              title: Text(strings.advancedActionsIncluded),
              content: Text(strings.advancedActionsDescription),
              severity: InfoBarSeverity.info,
              isLong: true,
            ),
          ),
        ..._buildCollections(context, tweaks),
      ],
    );
  }

  /// Groups the category entries into their collections, preserving the
  /// catalog order, and renders each one as a collapsible section. Sections
  /// start closed; the controller remembers the ones the user opens.
  List<Widget> _buildCollections(
    BuildContext context,
    List<TweakDescriptor> tweaks,
  ) {
    final grouped = <String, List<TweakDescriptor>>{};
    for (final descriptor in tweaks) {
      grouped
          .putIfAbsent(descriptor.collection, () => <TweakDescriptor>[])
          .add(descriptor);
    }

    return grouped.entries
        .map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Expander(
              // Keyed per collection so switching category never recycles
              // another collection's expansion state.
              key: ValueKey<String>('${widget.category}/${group.key}'),
              initiallyExpanded: widget.controller.isCollectionExpanded(
                widget.category,
                group.key,
              ),
              onStateChanged: (isExpanded) =>
                  widget.controller.setCollectionExpanded(
                    widget.category,
                    group.key,
                    isExpanded,
                  ),
              header: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        TweakTextLocalizer.collection(
                          group.key,
                          widget.controller.localeCode,
                        ),
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                    ),
                    Text(
                      '${group.value.length}',
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ],
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: group.value
                    .map((item) => _buildEntry(context, item))
                    .toList(growable: false),
              ),
            ),
          );
        })
        .toList(growable: false);
  }

  Future<bool> _promptRestorePoint() {
    final strings = AppLocalizations.of(context);
    return widget.onSafetyPrompt(
      strings.restorePointPromptTitle,
      strings.restorePointPromptMessage,
      confirmLabel: strings.createRestorePoint,
      cancelLabel: strings.skip,
    );
  }

  Widget _buildEntry(BuildContext context, TweakDescriptor descriptor) {
    final strings = AppLocalizations.of(context);
    final available = widget.controller.isDescriptorAvailable(descriptor);
    final busy = widget.controller.busyTweaks.contains(descriptor.id);
    final text = TweakTextLocalizer.resolve(
      descriptor,
      widget.controller.localeCode,
    );

    if (descriptor.isSystemToggle) {
      final needsReconnectHint = TweaksPage._networkReconnectHintToggleIds
          .contains(descriptor.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TweakSwitchTile(
          title: text.title,
          description: text.description,
          details: text.details,
          value: widget.controller.toggleStates[descriptor.id] ?? false,
          enabled: available,
          isBusy: busy,
          warning: descriptor.isAggressive
              ? strings.aggressiveTweakWarning
              : (needsReconnectHint ? strings.networkReconnectWarning : null),
          unavailableReason: available
              ? null
              : widget.controller.availabilityHint(descriptor),
          onChanged: (next) async {
            final result = await widget.controller.toggleSystemTweak(
              descriptor,
              next,
              confirmRestorePoint: _promptRestorePoint,
            );
            _reportFailure(result.success, result.message);
          },
        ),
      );
    }

    final scriptTweak = descriptor.scriptTweak!;
    final profileImport = scriptTweak is NvidiaProfileImportTweak
        ? scriptTweak
        : null;
    final profiles =
        profileImport?.availableProfiles() ?? const <NvidiaProfile>[];
    profileImport?.ensureSelection(profiles);

    if (scriptTweak.hasState) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TweakSwitchTile(
          title: text.title,
          description: text.description,
          details: text.details,
          value: scriptTweak.isApplied,
          enabled: available,
          isBusy: busy,
          warning: descriptor.isAggressive
              ? strings.aggressiveTweakWarning
              : null,
          unavailableReason: available
              ? null
              : widget.controller.availabilityHint(descriptor),
          onChanged: (_) async {
            final result = await widget.controller.runScriptAction(
              descriptor,
              confirmRestorePoint: _promptRestorePoint,
            );
            _reportFailure(result.success, result.message);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    text.title,
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  const SizedBox(height: 2),
                  if (widget.controller.wasScriptExecuted(descriptor.id))
                    Row(
                      children: <Widget>[
                        Icon(
                          FluentIcons.check_mark,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(strings.ran),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(text.description),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (profileImport != null) ...<Widget>[
                  SizedBox(
                    width: 260,
                    child: ComboBox<NvidiaProfile>(
                      value: profileImport.selectedProfile,
                      items: <ComboBoxItem<NvidiaProfile>>[
                        for (final profile in profiles)
                          ComboBoxItem<NvidiaProfile>(
                            value: profile,
                            child: Text(profile.name),
                          ),
                      ],
                      onChanged: busy
                          ? null
                          : (profile) => setState(
                              () => profileImport.selectProfile(profile),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(FluentIcons.info),
                  onPressed: () => _showTweakInfo(context, text),
                ),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: ProgressRing(strokeWidth: 2),
                    ),
                  ),
                FilledButton(
                  onPressed:
                      busy ||
                          !available ||
                          (profileImport != null && profiles.isEmpty)
                      ? null
                      : () async {
                          final warningMessage = text.warningMessage?.trim();

                          if (warningMessage != null &&
                              warningMessage.isNotEmpty) {
                            final accepted = await widget.onSafetyPrompt(
                              strings.actionWarning,
                              warningMessage,
                              confirmLabel: strings.continueAction,
                              cancelLabel: strings.cancel,
                            );
                            if (!accepted) {
                              return;
                            }
                          }

                          final result = await widget.controller
                              .runScriptAction(
                                descriptor,
                                confirmRestorePoint: _promptRestorePoint,
                              );
                          _reportFailure(result.success, result.message);
                        },
                  child: Text(text.actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reportFailure(bool success, String? message) {
    if (success || !mounted) {
      return;
    }

    final strings = AppLocalizations.of(context);
    displayInfoBar(
      context,
      builder: (_, close) => InfoBar(
        title: Text(strings.operationFailed),
        content: Text(message ?? strings.unknownError),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: InfoBarSeverity.error,
      ),
    );
  }

  void _showTweakInfo(BuildContext context, LocalizedTweakText text) {
    showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(text.title),
        content: Text(text.details),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }
}
