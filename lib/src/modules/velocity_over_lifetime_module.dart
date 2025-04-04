import 'package:vector_math/vector_math_64.dart' as vmath;

import '../components/min_max_curve.dart';

/// Vận tốc thay đổi theo thời gian. Kết quả được cộng với giá trị ban đầu.
class VelocityOverLifetimeModule {
  MinMaxCurve<double> velocityX;
  MinMaxCurve<double> velocityY;

  VelocityOverLifetimeModule({
    required this.velocityX,
    required this.velocityY,
  });

  factory VelocityOverLifetimeModule.twoConstants(
    vmath.Vector2 min,
    vmath.Vector2 max, {
    required bool inWorldSpace,
  }) {
    return VelocityOverLifetimeModule(
      velocityX: MinMaxCurve.linearTwoConstants(min.x, max.x),
      velocityY: MinMaxCurve.linearTwoConstants(min.y, max.y),
    );
  }

  vmath.Vector2 evaluate(double time) {
    return vmath.Vector2(velocityX.evaluate(time), velocityY.evaluate(time));
  }
}
