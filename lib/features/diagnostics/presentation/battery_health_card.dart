import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/battery_health_service.dart';

/// Battery health, one row per battery. Renders nothing on desktops.
class BatteryHealthSection extends StatefulWidget {
  const BatteryHealthSection({required this.load, super.key});

  final Future<BatterySnapshot> Function() load;

  @override
  State<BatteryHealthSection> createState() => _BatteryHealthSectionState();
}

class _BatteryHealthSectionState extends State<BatteryHealthSection> {
  BatterySnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    widget
        .load()
        .then((snapshot) {
          if (mounted) setState(() => _snapshot = snapshot);
        })
        // A failed read hides the section like a desktop does.
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null || !snapshot.hasBattery) {
      return const SizedBox.shrink();
    }
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(strings.batteryHealth, style: theme.typography.subtitle),
              const SizedBox(height: 6),
              Text(strings.batteryHealthDescription),
              for (final battery in snapshot.batteries) ...<Widget>[
                const SizedBox(height: 16),
                _BatteryRow(battery: battery),
              ],
              const SizedBox(height: 12),
              SourceCaption(
                snapshot.source == BatterySource.report
                    ? strings.batterySourceReport
                    : strings.batterySourceWmi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryRow extends StatelessWidget {
  const _BatteryRow({required this.battery});

  final BatteryHealth battery;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final health = battery.healthPercent;
    final band = battery.band;
    final (label, tone, icon) = switch (band) {
      BatteryHealthBand.good => (
        strings.batteryGood,
        BadgeTone.positive,
        FluentIcons.completed,
      ),
      BatteryHealthBand.fair => (
        strings.batteryFair,
        BadgeTone.caution,
        FluentIcons.warning,
      ),
      BatteryHealthBand.poor => (
        strings.batteryPoor,
        BadgeTone.critical,
        FluentIcons.error_badge,
      ),
      null => (strings.notAvailable, BadgeTone.neutral, null),
    };
    String mwh(int? value) =>
        value == null ? strings.notAvailable : '$value mWh';
    final stats = <(String, String)>[
      (strings.batteryDesigned, mwh(battery.designedMwh)),
      (strings.batteryFullCharge, mwh(battery.fullChargedMwh)),
      (
        strings.batteryWear,
        battery.wearPercent == null
            ? strings.notAvailable
            : '${battery.wearPercent}%',
      ),
      (
        strings.batteryCycles,
        battery.cycles?.toString() ?? strings.notAvailable,
      ),
      (
        strings.batteryCharge,
        <String>[
          battery.chargePercent == null
              ? strings.notAvailable
              : '${battery.chargePercent}%',
          if (battery.onAcPower != null)
            battery.onAcPower! ? strings.batteryOnAc : strings.batteryOnBattery,
        ].join(' · '),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          label:
              '${strings.batteryHealth} ${battery.name}: '
              '${health == null ? strings.notAvailable : '$health%'}, $label',
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomPaint(
                  size: const Size(112, 52),
                  painter: BatteryGlyphPainter(
                    fraction: health == null ? null : health / 100,
                    fill: StatusBadge.toneColor(tone),
                    outline: theme.resources.textFillColorSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      health == null ? strings.notAvailable : '$health%',
                      style: theme.typography.title,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (band != null) ...<Widget>[
                          StatusBadge(label, tone: tone, icon: icon),
                          const SizedBox(width: 8),
                        ],
                        Text(battery.name, style: theme.typography.caption),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: <Widget>[
            for (final (name, value) in stats)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: theme.typography.caption),
                  Text(value, style: theme.typography.bodyStrong),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Battery outline with a terminal nub, filled left to right by [fraction].
/// A null fraction draws only the outline: nothing was measured.
class BatteryGlyphPainter extends CustomPainter {
  const BatteryGlyphPainter({
    required this.fraction,
    required this.fill,
    required this.outline,
  });

  final double? fraction;
  final Color? fill;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0, nub = 6.0, gap = 2.0;
    final body = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - nub - stroke,
      size.height - stroke,
    );
    final line = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      line,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          body.right + stroke / 2,
          size.height * 0.32,
          nub,
          size.height * 0.36,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = outline,
    );
    final value = fraction;
    if (value == null || fill == null || value <= 0) return;
    final inner = body.deflate(stroke / 2 + gap);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inner.left,
          inner.top,
          inner.width * value.clamp(0.0, 1.0),
          inner.height,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = fill!,
    );
  }

  @override
  bool shouldRepaint(BatteryGlyphPainter old) =>
      old.fraction != fraction || old.fill != fill || old.outline != outline;
}
