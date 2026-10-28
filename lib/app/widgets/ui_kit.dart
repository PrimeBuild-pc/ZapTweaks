import 'package:fluent_ui/fluent_ui.dart';

import '../../l10n/app_localizations.dart';

/// Shared building blocks so every page shows the same thing the same way.

enum BadgeTone { neutral, positive, caution, critical }

/// Small labelled chip. The label always carries the meaning; color only
/// reinforces it.
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.label, {
    this.tone = BadgeTone.neutral,
    this.icon,
    this.tooltip,
    super.key,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final String? tooltip;

  // Status steps validated for 3:1 on dark surfaces; on light ones the label
  // and icon carry the meaning (dataviz status palette).
  static const good = Color(0xFF0CA30C);
  static const warning = Color(0xFFFAB219);
  static const critical = Color(0xFFD03B3B);

  static Color? toneColor(BadgeTone tone) => switch (tone) {
    BadgeTone.neutral => null,
    BadgeTone.positive => good,
    BadgeTone.caution => warning,
    BadgeTone.critical => critical,
  };

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color = toneColor(tone);
    final stroke = color ?? theme.resources.controlStrokeColorDefault;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: stroke),
        color: color?.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: theme.typography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? badge : Tooltip(message: tooltip, child: badge);
  }
}

/// "by Author" chip for third-party scripts and apps. Native tweaks have none.
class AttributionBadge extends StatelessWidget {
  const AttributionBadge(this.author, {super.key});

  final String author;

  @override
  Widget build(BuildContext context) => StatusBadge('by $author');
}

/// Caption naming where a value was read from.
class SourceCaption extends StatelessWidget {
  const SourceCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(FluentIcons.info, size: 11),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: theme.typography.caption)),
      ],
    );
  }
}

/// Message shown instead of a blank area when a list has nothing to show.
class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {this.actionLabel, this.onAction, super.key});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: 12),
            Button(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}

/// Standard confirmation: Cancel on the left, the action on the right.
/// Destructive actions get a red confirm button.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final strings = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ContentDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        Button(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? strings.cancel),
        ),
        FilledButton(
          style: destructive
              ? ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red))
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Page title, in the same place and size on every page.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});

  final String title;

  static const padding = EdgeInsets.fromLTRB(20, 20, 20, 12);

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(title, style: FluentTheme.of(context).typography.title),
  );
}

/// Tabs of a section: each tab as wide as its label, so none is cut off.
class SectionTabView extends StatelessWidget {
  const SectionTabView({
    required this.currentIndex,
    required this.onChanged,
    required this.tabs,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) => TabView(
    currentIndex: currentIndex,
    onChanged: onChanged,
    closeButtonVisibility: CloseButtonVisibilityMode.never,
    tabWidthBehavior: TabWidthBehavior.sizeToContent,
    tabs: tabs,
  );
}

/// Group heading above a run of [SettingsCard]s (Windows 11 Settings).
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ),
        for (var i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 4),
          children[i],
        ],
      ],
    ),
  );
}

/// One setting or action: icon, title, description, control on the right
/// (Windows 11 SettingsCard). [footer] holds extra content below.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    this.description,
    this.icon,
    this.trailing,
    this.footer,
    super.key,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(title, style: theme.typography.body),
                      if (description != null && description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            description!,
                            style: theme.typography.caption?.copyWith(
                              color: theme.resources.textFillColorSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: 16),
                  trailing!,
                ],
              ],
            ),
          ),
          if (footer != null) ...<Widget>[const SizedBox(height: 12), footer!],
        ],
      ),
    );
  }
}
