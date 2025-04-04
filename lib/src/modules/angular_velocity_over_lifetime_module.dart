// import 'dart:math';

// import 'package:vector_math/vector_math_64.dart' as vmath;

// import '../components/min_max_curve.dart';

// /// Unity là RotationOverLifetime (thực chất là velocity).
// /// Tốc độ xoay mỗi giây của mỗi particle.
// /// Hướng thể hiện trục xoay và độ lớn thể hiện vận tốc.
// /// Cái tên Lifetime mà Unity đặt cho nó không phản ánh nó sẽ thay đổi theo thời gian
// class AngularVelocityOverLifetimeModule {
//   MinMaxCurve<double> angularVelocityX;
//   MinMaxCurve<double> angularVelocityY;
//   MinMaxCurve<double> angularVelocityZ;
//   final ParticleSystemCurveMode mode;

//   AngularVelocityOverLifetimeModule._({
//     required this.angularVelocityX,
//     required this.angularVelocityY,
//     required this.angularVelocityZ,
//     required this.mode,
//   });

//   factory AngularVelocityOverLifetimeModule.twoConstants(
//     vmath.Vector3 from,
//     vmath.Vector3 to,
//   ) {
//     return AngularVelocityOverLifetimeModule._(
//       angularVelocityX: MinMaxCurve.twoConstants(from.x, to.x),
//       angularVelocityY: MinMaxCurve.twoConstants(from.y, to.y),
//       angularVelocityZ: MinMaxCurve.twoConstants(from.z, to.z),
//       mode: ParticleSystemCurveMode.curve,
//     );
//   }

//   final Map<int, vmath.Vector3> _angularVelocityMap = {};

//   /// TODO: Thêm một MAP, để lưu particle nào đã cố định angularVelocity.
//   /// để truy vấn có thể dùng get, nếu
//   vmath.Vector3 getAngularVelocity(int particleId) {
//     if (mode == ParticleSystemCurveMode.constant) {
//       vmath.Vector3? result = _angularVelocityMap[particleId];
//       if (result == null) {
//         result = vmath.Vector3(
//           angularVelocityX.random(),
//           angularVelocityX.random(),
//           angularVelocityX.random(),
//         );

//         _angularVelocityMap[particleId] = result;
//       }

//       return result;
//     }

//     return;
//   }
// }
