import 'package:flutter/material.dart';

import 'particle_system.dart';

class ParticlePainter extends CustomPainter {
  final ParticleSystem particleSystem;
  final bool debug;

  ParticlePainter(
    this.particleSystem, {
    this.debug = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    particleSystem.render(canvas, debug);

    if (debug) {
      final borderPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
