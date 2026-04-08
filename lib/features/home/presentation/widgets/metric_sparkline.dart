import 'package:fluent_ui/fluent_ui.dart';

class MetricSparkline extends StatelessWidget {
  const MetricSparkline({
    super.key,
    required this.values,
    required this.color,
    this.minY = 0,
    this.maxY = 100,
  });

  final List<double> values;
  final Color color;
  final double minY;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        values: values,
        color: color,
        minY: minY,
        maxY: maxY,
      ),
      size: const Size(double.infinity, 64),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.color,
    required this.minY,
    required this.maxY,
  });

  final List<double> values;
  final Color color;
  final double minY;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final baseline = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height);
    canvas.drawPath(baseline, baselinePaint);

    if (values.length < 2 || maxY <= minY) {
      return;
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          color.withValues(alpha: 0.34),
          color.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);

    for (var index = 0; index < values.length; index++) {
      final value = values[index].clamp(minY, maxY);
      final normalized = (value - minY) / (maxY - minY);
      final x = stepX * index;
      final y = size.height - (normalized * size.height);

      if (index == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    if (oldDelegate.values.length != values.length ||
        oldDelegate.color != color ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY) {
      return true;
    }

    for (var index = 0; index < values.length; index++) {
      if (values[index] != oldDelegate.values[index]) {
        return true;
      }
    }

    return false;
  }
}
