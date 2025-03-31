import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract class ParticleSystemShape {
  final random = math.Random();

  Offset getSpawnPosition();
  Offset getDirection();
  Path getShapePath();
}

Offset _rotateDirection(Offset direction, double rotation) {
  double cosAngle = math.cos(-rotation);
  double sinAngle = math.sin(-rotation);

  double rotatedX = direction.dx * cosAngle - direction.dy * sinAngle;
  double rotatedY = direction.dx * sinAngle + direction.dy * cosAngle;

  return Offset(rotatedX, rotatedY);
}

Path _rotatePath(Path path, double rotation) {
  final Matrix4 matrix =
      Matrix4.identity()
        ..translate(0.0, 0.0)
        ..rotateZ(-rotation);

  return path.transform(matrix.storage);
}

Offset _rotatePoint(double x, double y, double rotation) {
  double cosAngle = math.cos(-rotation);
  double sinAngle = math.sin(-rotation);

  double rotatedX = x * cosAngle - y * sinAngle;
  double rotatedY = x * sinAngle + y * cosAngle;

  return Offset(rotatedX, rotatedY);
}

class ConeShape extends ParticleSystemShape {
  final double angle; // Góc tạo bởi hình nón
  final double radius; // Bán kính của phần gốc
  final double rotation; // Độ xoay của hình nón

  ConeShape({
    required this.angle,
    required this.radius,
    required this.rotation,
  });

  @override
  Offset getSpawnPosition() {
    double x = 0;
    double y = random.nextDouble() * 2 * radius - radius;

    return _rotatePoint(x, y, rotation);
  }

  @override
  Offset getDirection() {
    double halfAngle = angle / 2;
    double spread = (random.nextDouble() * angle) - halfAngle;

    // Vector hướng mặc định trong Unity là (1, 0) - sang phải
    Offset direction = Offset(math.cos(spread), math.sin(spread));

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
