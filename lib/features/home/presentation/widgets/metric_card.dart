import 'package:fluent_ui/fluent_ui.dart';

import 'metric_sparkline.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.history,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final List<double> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FluentTheme.of(context).typography.titleLarge,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              width: double.infinity,
              child: MetricSparkline(values: history, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
