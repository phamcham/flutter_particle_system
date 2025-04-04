import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' as vmath;

import '../../flutter_particle_system.dart';

class MainModule {
  int maxParticles;

  /// Số particle được emit mỗi giây
  int rateOverTime;
  ParticleSystemShape shape;

  MinMaxCurve<double> lifetime;
  MinMaxCurve<double> speed;
  MinMaxCurve<vmath.Vector3> angularVelocity;
  MinMaxCurve<Size> size;
  MinMaxCurve<double> scale;
  MinMaxCurve<double> opacity;
  ColorOverLifetimeModuleGradient color;

  /// [yaw], [pitch] and [roll].
  MinMaxCurve<vmath.Vector3> rotation;

  MainModule({
    required this.maxParticles,
    required this.rateOverTime,
    required this.shape,
    required this.lifetime,
    required this.speed,
    required this.angularVelocity,
    required this.size,
    required this.scale,
    required this.opacity,
    required this.color,
    required this.rotation,
  });
}
