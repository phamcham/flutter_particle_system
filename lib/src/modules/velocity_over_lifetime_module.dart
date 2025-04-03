import 'package:vector_math/vector_math_64.dart' as vmath;

import '../components/lerpable.dart';

/// Vận tốc thay đổi theo thời gian. Kết quả được cộng với giá trị ban đầu.
class VelocityOverLifetimeModule {
  Lerpable<vmath.Vector2> linear;
  bool inWorldSpace;

  VelocityOverLifetimeModule({
    required this.linear,
    required this.inWorldSpace,
  });
}
