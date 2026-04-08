import 'package:fluent_ui/fluent_ui.dart';

class TweakSwitchTile extends StatelessWidget {
  const TweakSwitchTile({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.enabled,
    required this.isBusy,
    required this.onChanged,
    this.busyDuration = Duration.zero,
    this.warning,
    this.unavailableReason,
  });

  final String title;
  final String description;
  final bool value;
  final bool enabled;
  final bool isBusy;
  final Duration busyDuration;
  final String? warning;
  final String? unavailableReason;
  final Future<void> Function(bool next) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isBusy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: ProgressRing(strokeWidth: 2),
                )
              else
                ToggleSwitch(
                  checked: value,
                  onChanged: enabled ? (next) => onChanged(next) : null,
                ),
            ],
          ),
          if (isBusy && busyDuration >= const Duration(seconds: 2)) ...<Widget>[
            const SizedBox(height: 10),
            const Text('In progress...'),
            const SizedBox(height: 6),
            const ProgressBar(),
          ],
          if (warning != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: const Text('Safety warning'),
              content: Text(warning!),
              severity: InfoBarSeverity.warning,
              isLong: true,
            ),
          ],
          if (!enabled && unavailableReason != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: const Text('Unavailable'),
              content: Text(unavailableReason!),
              severity: InfoBarSeverity.info,
              isLong: true,
            ),
          ],
        ],
      ),
    );
  }
}
