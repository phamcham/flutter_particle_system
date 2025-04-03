import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

abstract class ParticleSystemShape {
  final random = math.Random();

  vmath.Vector2 getSpawnPosition();
  vmath.Vector2 getDirection();
  Path getShapePath();
}

vmath.Vector2 _rotateDirection(vmath.Vector2 direction, double angleRadians) {
  final rotationMatrix = vmath.Matrix2.rotation(-angleRadians);
  return rotationMatrix.transformed(direction);
}

Path _rotatePath(Path path, double rotation) {
  final Matrix4 matrix =
      Matrix4.identity()
        ..translate(0.0, 0.0)
        ..rotateZ(-rotation);

  return path.transform(matrix.storage);
}

vmath.Vector2 _rotatePoint(
  vmath.Vector2 point,
  vmath.Vector2 pivot,
  double angleRadians,
) {
  final translated = point - pivot;
  final rotated = vmath.Matrix2.rotation(-angleRadians).transformed(translated);

  return rotated + pivot;
}

class ConeShape extends ParticleSystemShape {
  /// Góc tạo bởi hình nón
  final double angle;

  /// Bán kính của phần gốc
  final double radius;

  /// Độ xoay của hình nón
  final double rotation;

  ConeShape({
    required this.angle,
    required this.radius,
    required this.rotation,
  });

  @override
  vmath.Vector2 getSpawnPosition() {
    final position = vmath.Vector2(
      0,
      random.nextDouble() * 2 * radius - radius,
    );

    return _rotatePoint(position, vmath.Vector2.zero(), rotation);
  }

  @override
  vmath.Vector2 getDirection() {
    double halfAngle = angle / 2;
    double spread = (random.nextDouble() * angle) - halfAngle;

    // Vector hướng mặc định trong Unity là (1, 0) - sang phải
    final direction = vmath.Vector2(math.cos(spread), math.sin(spread));

    return _rotateDirection(direction, rotation);
  }

  @override
  Path getShapePath() {
    Path path = Path();

    final halfAngle = angle / 2;

    // Đáy nhỏ
    final smallBaseLeft = Offset(0, -radius);
    final smallBaseRight = Offset(0, radius);

    // Đáy lớn
    final height = radius * 2;
    final deltaY = height * math.tan(halfAngle);
    final largeBaseLeft = Offset(height, -radius - deltaY);
    final largeBaseRight = Offset(height, radius + deltaY);

    // Vẽ hình thang
    path.moveTo(smallBaseLeft.dx, smallBaseLeft.dy);
    path.lineTo(largeBaseLeft.dx, largeBaseLeft.dy);
    path.lineTo(largeBaseRight.dx, largeBaseRight.dy);
    path.lineTo(smallBaseRight.dx, smallBaseRight.dy);
    path.close();

    final direction = Offset(3 * radius, 0);

    path.moveTo(0, 0);
    path.lineTo(0 + direction.dx, 0 + direction.dy);

    path.close();

    return _rotatePath(path, rotation);
  }
}
