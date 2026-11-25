import 'dart:math';
import 'package:flutter/material.dart';

class CuteWeatherArt extends StatelessWidget {
  final int weatherCode;
  final double size;

  const CuteWeatherArt({
    super.key,
    required this.weatherCode,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _CuteWeatherPainter(weatherCode: weatherCode),
      ),
    );
  }
}

class _CuteWeatherPainter extends CustomPainter {
  final int weatherCode;

  _CuteWeatherPainter({required this.weatherCode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 6);

    // Weather type grouping
    final isRainy = (weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82);
    final isSunny = weatherCode == 0 || weatherCode == 1;
    final isStormy = weatherCode >= 95;
    final hasSun = isSunny || isRainy || (weatherCode >= 2 && weatherCode <= 3);

    // 1. Draw Sun in the background (top-right of the cloud)
    if (hasSun && !isStormy) {
      final sunCenter = Offset(center.dx + 26, center.dy - 16);
      final sunRadius = size.width * 0.17;

      // Sun rays (dashed circle or small rays)
      final rayPaint = Paint()
        ..color = const Color(0xFFFDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 8; i++) {
        final angle = (i * pi / 4);
        final start = Offset(
          sunCenter.dx + (sunRadius + 3) * cos(angle),
          sunCenter.dy + (sunRadius + 3) * sin(angle),
        );
        final end = Offset(
          sunCenter.dx + (sunRadius + 8) * cos(angle),
          sunCenter.dy + (sunRadius + 8) * sin(angle),
        );
        canvas.drawLine(start, end, rayPaint);
      }

      // Sun body
      final sunPaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sunCenter, sunRadius, sunPaint);
    }

    // 2. Draw Cloud Body (white fluffy cloud with soft shadow)
    final cloudOffset = Offset(center.dx - 8, center.dy);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final cloudPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path getCloudPath(Offset origin) {
      final path = Path();
      // Base rounded rectangle
      final baseRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(origin.dx, origin.dy + 8),
          width: size.width * 0.58,
          height: size.height * 0.32,
        ),
        const Radius.circular(16),
      );
      path.addRRect(baseRect);

      // Cloud puffs (circles)
      path.addOval(Rect.fromCircle(
        center: Offset(origin.dx - 18, origin.dy),
        radius: size.width * 0.14,
      ));
      path.addOval(Rect.fromCircle(
        center: Offset(origin.dx + 6, origin.dy - 6),
        radius: size.width * 0.18,
      ));
      path.addOval(Rect.fromCircle(
        center: Offset(origin.dx + 26, origin.dy + 4),
        radius: size.width * 0.12,
      ));
      return path;
    }

    // Draw shadow then cloud
    canvas.drawPath(getCloudPath(cloudOffset.translate(0, 3)), shadowPaint);
    canvas.drawPath(getCloudPath(cloudOffset), cloudPaint);

    // 3. Cute kawaii face on the cloud (Two eyes and a smile)
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(Offset(cloudOffset.dx - 4, cloudOffset.dy + 6), 2.2, eyePaint);
    // Right eye
    canvas.drawCircle(Offset(cloudOffset.dx + 16, cloudOffset.dy + 6), 2.2, eyePaint);

    // Cute blush cheeks (pink)
    final blushPaint = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cloudOffset.dx - 9, cloudOffset.dy + 10), 3.0, blushPaint);
    canvas.drawCircle(Offset(cloudOffset.dx + 21, cloudOffset.dy + 10), 3.0, blushPaint);

    // Cute curved smile
    final smilePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cloudOffset.dx + 3, cloudOffset.dy + 8);
    smilePath.quadraticBezierTo(
      cloudOffset.dx + 6,
      cloudOffset.dy + 12,
      cloudOffset.dx + 9,
      cloudOffset.dy + 8,
    );
    canvas.drawPath(smilePath, smilePaint);

    // 4. Draw Raindrops if rainy (3 cute water droplets)
    if (isRainy || isStormy) {
      final dropPaint = Paint()
        ..color = const Color(0xFF93C5FD).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      void drawDroplet(Offset pos) {
        final path = Path();
        path.moveTo(pos.dx, pos.dy - 6);
        path.quadraticBezierTo(pos.dx + 3, pos.dy, pos.dx, pos.dy + 3);
        path.quadraticBezierTo(pos.dx - 3, pos.dy, pos.dx, pos.dy - 6);
        path.close();
        canvas.drawPath(path, dropPaint);
      }

      drawDroplet(Offset(cloudOffset.dx - 12, cloudOffset.dy + 30));
      drawDroplet(Offset(cloudOffset.dx + 6, cloudOffset.dy + 34));
      drawDroplet(Offset(cloudOffset.dx + 24, cloudOffset.dy + 30));
    }
  }

  @override
  bool shouldRepaint(covariant _CuteWeatherPainter oldDelegate) =>
      oldDelegate.weatherCode != weatherCode;
}
