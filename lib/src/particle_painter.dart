import 'package:flutter/material.dart';

import 'particle_system.dart';

class ParticlePainter extends CustomPainter {
  final ParticleSystem particleSystem;

  ParticlePainter(this.particleSystem);

  @override
  void paint(Canvas canvas, Size size) {
    particleSystem.render(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
