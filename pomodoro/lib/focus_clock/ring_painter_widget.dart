import 'package:flutter/material.dart';
import 'dart:math';

class RingPainterSettings {
  double percent = 0.0;
  Color ringBackgroundColor = const Color.fromARGB(255, 177, 177, 177);
  Color ringForegroundColor = const Color.fromARGB(255, 235, 73, 73);
  String time = "00:00";
  String plan = "FOCUS";
  Color ringTimeTextColor = const Color.fromARGB(255, 255, 255, 255);
}

class RingPainterWidget extends StatelessWidget {
  const RingPainterWidget({
    super.key,
    required this.settings,
  });

  final RingPainterSettings settings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
          size: const Size(300, 300), painter: RingPainter(settings)),
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter(this.settings);

  final RingPainterSettings settings;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width / 25.0;
    final strokeWidth1 = size.width / 90.0; // background
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth1
      ..color = settings.ringBackgroundColor
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    final foregroundPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = settings.ringForegroundColor
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2 * pi * (1 - settings.percent) - pi / 2,
      2 * pi * settings.percent,
      false,
      foregroundPaint,
    );

// paint time text
    var timeTextSpan = TextSpan(
        text: settings.time,
        style: TextStyle(
            color: settings.ringTimeTextColor,
            fontWeight: FontWeight.normal,
            fontSize: 60));

    var timeTextPainter = TextPainter(
        text: timeTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    timeTextPainter.layout();

    var fontOffset = Offset((size.width - timeTextPainter.size.width) / 2,
        (size.height - timeTextPainter.size.height) / 2);

    timeTextPainter.paint(canvas, fontOffset);

// paint plan name
    var planTextSpan = TextSpan(
        text: settings.plan,
        style: TextStyle(
            color: settings.ringTimeTextColor,
            fontWeight: FontWeight.normal,
            fontSize: 20));

    var planTextPainter = TextPainter(
        text: planTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    planTextPainter.layout();

    var planFontOffset = Offset(
        (size.width - planTextPainter.size.width) / 2,
        (size.height - planTextPainter.size.height) / 2 +
            timeTextPainter.size.height -
            10);

    planTextPainter.paint(canvas, planFontOffset);
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.settings.percent != settings.percent ||
      oldDelegate.settings.time != settings.time ||
      oldDelegate.settings.ringForegroundColor !=
          settings.ringForegroundColor ||
      oldDelegate.settings.ringBackgroundColor !=
          settings.ringBackgroundColor ||
      oldDelegate.settings.ringTimeTextColor != settings.ringTimeTextColor;
}
