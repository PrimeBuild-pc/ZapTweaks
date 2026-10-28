import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../diagnostics/presentation/app_history_page.dart' show formatBytes;
import '../application/app_list_query.dart';
import '../domain/app_package.dart';
import '../domain/app_safety_policy.dart';

/// One row of the installed-apps list: name and facts on the left, size bar,
/// type and safety badges and install date as fixed columns, action last.
class InstalledAppRow extends StatelessWidget {
  const InstalledAppRow({
    required this.app,
    required this.maxSizeBytes,
    required this.selected,
    required this.onSelected,
    this.action,
    super.key,
  });

  final AppPackage app;
  final int maxSizeBytes;
  final bool selected;

  /// Null when the app cannot be queued for removal.
  final ValueChanged<bool>? onSelected;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final verdict = classifyApp(app);
    final (safetyLabel, tone) = switch (verdict.safety) {
      AppSafety.removable => (strings.appSafetyRemovable, BadgeTone.positive),
      AppSafety.checkFirst => (strings.appSafetyCheckFirst, BadgeTone.caution),
      AppSafety.keep => (strings.appSafetyKeep, BadgeTone.critical),
    };
    final size = app.sizeBytes;
    final date = app.installDate;
    final dateText = date == null
        ? '—'
        : '${date.year}-${_two(date.month)}-${_two(date.day)}';
    final typeText = switch (appTypeOf(app)) {
      AppType.system => strings.appTypeSystem,
      AppType.user => strings.appTypeUser,
      AppType.store => strings.appTypeStore,
    };
    // Narrow windows fold type and date into the caption.
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Checkbox(
            checked: selected,
            onChanged: onSelected == null ? null : (v) => onSelected!(v!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  app.name,
                  style: theme.typography.bodyStrong,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  <String>[
                    if (app.publisher != null) _publisher(app.publisher!),
                    if (app.version != null) app.version!,
                    if (!wide) ...<String>[typeText, dateText],
                  ].join(' · '),
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _reason(strings, verdict.reason),
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                if (app.labels.difference({AppLabel.storeApp}).isNotEmpty ||
                    app.wingetId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final label in app.labels)
                          if (label != AppLabel.storeApp)
                            StatusBadge(_label(strings, label)),
                        if (app.wingetId != null)
                          Text(
                            strings.reinstallableVia(app.wingetId!),
                            style: theme.typography.caption,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: wide ? 130 : 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(size == null ? '—' : formatBytes(size)),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.resources.controlStrokeColorDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: size == null || maxSizeBytes <= 0
                        ? 0
                        : (size / maxSizeBytes).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (wide) SizedBox(width: 80, child: StatusBadge(typeText)),
          SizedBox(
            width: 120,
            child: StatusBadge(
              safetyLabel,
              tone: tone,
              tooltip: _reason(strings, verdict.reason),
            ),
          ),
          if (wide)
            Container(
              width: 98,
              padding: const EdgeInsets.only(left: 8),
              child: Text(dateText, style: theme.typography.caption),
            ),
          if (action != null) ...<Widget>[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// AppX publishers are certificate names: show O= (or CN=) only.
  static String _publisher(String value) {
    if (!value.startsWith('CN=')) return value;
    final fields = <String, String>{
      for (final part in value.split(','))
        if (part.contains('='))
          part.split('=').first.trim(): part.split('=').skip(1).join('='),
    };
    return fields['O'] ?? fields['CN'] ?? value;
  }

  static String _reason(AppLocalizations strings, AppSafetyReason reason) =>
      switch (reason) {
        AppSafetyReason.systemComponent => strings.appReasonSystemComponent,
        AppSafetyReason.protected => strings.appReasonProtected,
        AppSafetyReason.update => strings.appReasonUpdate,
        AppSafetyReason.windowsPart => strings.appReasonWindowsPart,
        AppSafetyReason.sharedDependency => strings.appReasonSharedDependency,
        AppSafetyReason.optionalFeature => strings.appReasonOptionalFeature,
        AppSafetyReason.missingUninstaller =>
          strings.appReasonMissingUninstaller,
        AppSafetyReason.userInstalled => strings.appReasonUserInstalled,
      };

  static String _label(AppLocalizations strings, AppLabel label) =>
      switch (label) {
        AppLabel.missingUninstaller => strings.appLabelMissingUninstaller,
        AppLabel.protected => strings.appLabelProtected,
        AppLabel.systemComponent => strings.appLabelSystemComponent,
        AppLabel.update => strings.appLabelUpdate,
        AppLabel.storeApp => strings.appTypeStore,
      };
}
