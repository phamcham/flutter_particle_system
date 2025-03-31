import 'dart:math';

import 'package:flutter/material.dart';

import 'components/particle_system_shape.dart';
import 'components/value_range.dart';
import 'particle.dart';

class ParticleSystem {
  List<Particle> particles = [];

  double duration;
  bool looping;

  // Lerpable<double> startDelay;
  Lerpable<double> startLifetime;
  Lerpable<double> startVelocity;
  Lerpable<double>? speedOverLifetime;
  Lerpable<double> startRotationVelocity;
  Lerpable<double>? rotationSpeedOverLifetime;
  Lerpable<double> startSizeX;
  Lerpable<double>? sizeXOverLifetime;
  Lerpable<double> startSizeY;
  Lerpable<double>? sizeYOverLifetime;
  Lerpable<double> startRotation;
  Lerpable<double> startScale;
  Lerpable<double> startOpacity;
  Lerpable<double>? opacityOverLifetime;
  Lerpable<Color> startColor;
  Lerpable<Color>? colorOverLifetime;

  int maxParticles;

  /// Số particle được emit mỗi giây
  int rateOverTime;

  ParticleSystemShape shape;

  double _timeSinceLastEmission = 0;
  double _systemElapsedTime = 0;

  final Random _random = Random();

  ParticleSystem({
    required this.duration,
    required this.looping,
    // required this.startDelay,
    required this.startLifetime,
    required this.startVelocity,
    required this.startRotationVelocity,
    this.rotationSpeedOverLifetime,
    this.speedOverLifetime,
    required this.startSizeX,
    this.sizeXOverLifetime,
    required this.startSizeY,
    this.sizeYOverLifetime,
    required this.startRotation,
    required this.startScale,
    required this.startColor,
    this.colorOverLifetime,
    required this.startOpacity,
    this.opacityOverLifetime,
    required this.maxParticles,
    required this.rateOverTime,
    required this.shape,
  });

  void update(double deltaTime) {
    _timeSinceLastEmission += deltaTime;
    _systemElapsedTime += deltaTime;

    // print(_timeSinceLastEmission);

    // Xóa các particle đã hết thời gian sống
    final removedParticles = particles.where((p) => p.age >= p.lifetime);
    for (var removedParticle in removedParticles) {
      removedParticle.dispose();
    }
    particles.removeWhere((p) => removedParticles.any((e) => e.id == p.id));

    // Tính số particle cần phát
    int particlesToEmit = 0;
    if (_systemElapsedTime < duration || looping) {
      /// có thể emit thêm particle
      particlesToEmit = (rateOverTime * _timeSinceLastEmission).floor();
      _timeSinceLastEmission -= particlesToEmit / rateOverTime;
    }

    for (int i = 0;
        i < particlesToEmit && particles.length < maxParticles;
        i++) {
      _emitParticle();
    }

    /// update transform of particles
    for (var particle in particles) {
      final lifeProgress = particle.age / particle.lifetime;

      // Cập nhật vị trí
      particle.current.position += particle.current.velocity * deltaTime;
      particle.current.rotation +=
          particle.current.rotationVelocity * deltaTime;
      particle.age += deltaTime;

      particle.current.color =
          _applyColorAtProgress(particle.initial.color, lifeProgress);

      particle.current.opacity =
          _applyOpacityAtProgress(particle.initial.opacity, lifeProgress);

      particle.current.size =
          _applySizeAtProgress(particle.initial.size, lifeProgress);

      particle.current.velocity =
          _applyVelocityAtProgress(particle.initial.velocity, lifeProgress);

      particle.current.rotationVelocity = _applyRotationVelocityAtProgress(
          particle.initial.rotationVelocity, lifeProgress);
    }
  }

  Color _applyColorAtProgress(Color color, double lifeProgress) {
    if (colorOverLifetime != null) {
      final progressColor = colorOverLifetime!.valueAt(lifeProgress);
      color = Color.alphaBlend(color, progressColor);
    }
    return color;
  }

  double _applyOpacityAtProgress(double opacity, double lifeProgress) {
    if (opacityOverLifetime != null) {
      final progressOpacity = opacityOverLifetime!.valueAt(lifeProgress);
      opacity = opacity * progressOpacity;
    }

    return opacity;
  }

  Size _applySizeAtProgress(Size size, double lifeProgress) {
    if (sizeXOverLifetime != null) {
      final progressSizeX = sizeXOverLifetime!.valueAt(lifeProgress);
      size = Size(size.width * progressSizeX, size.height);
    }

    if (sizeYOverLifetime != null) {
      final progressSizeY = sizeYOverLifetime!.valueAt(lifeProgress);
      size = Size(size.width, size.height * progressSizeY);
    }

    return size;
  }

  Offset _applyVelocityAtProgress(Offset velocity, double lifeProgress) {
    if (speedOverLifetime != null) {
      final progressSpeed = speedOverLifetime!.valueAt(lifeProgress);
      velocity = velocity * progressSpeed;
    }

    return velocity;
  }

  double _applyRotationVelocityAtProgress(
      double rotationVelocity, double lifeProgress) {
    if (rotationSpeedOverLifetime != null) {
      final progressSpeed = rotationSpeedOverLifetime!.valueAt(lifeProgress);
      rotationVelocity = rotationVelocity * progressSpeed;
    }

    return rotationVelocity;
  }

  void _emitParticle() {
    final spawnPosition = shape.getSpawnPosition();
    final direction = shape.getDirection();

    final velocity = direction * _getRandomValue(startVelocity);
    final lifetime = _getRandomValue(startLifetime);
    final size = Size(
      _getRandomValue(startSizeX),
      _getRandomValue(startSizeY),
    );
    final color = _getRandomValue(startColor);
    final rotation = _getRandomValue(startRotation);
    final scale = _getRandomValue(startScale);
    final opacity = _getRandomValue(startOpacity);
    final rotationVelocity = _getRandomValue(startRotationVelocity);

    particles.add(Particle(
      position: spawnPosition,
      velocity: velocity,
      scale: scale,
      size: size,
      lifetime: lifetime,
      color: color,
      rotation: rotation,
      rotateVelocity: rotationVelocity,
      opacity: opacity,
    ));
  }

  T _getRandomValue<T>(Lerpable<T> lerper) {
    return lerper.valueAt(_random.nextDouble());
  }

  void render(Canvas canvas, bool debugMode) {
    for (var particle in particles) {
      final paint = Paint();
      canvas.save();
      // TODO: thêm rotation
      // canvas.translate(particle.position.dx, particle.position.dy);
      // canvas.rotate(particle.rotation);

      final state = particle.current;
      if (particle.image != null) {
        final src = Rect.fromLTWH(0, 0, particle.image!.width.toDouble(),
            particle.image!.height.toDouble());
        final dst = Rect.fromCenter(
          center: state.position,
          width: state.size.width,
          height: state.size.height,
        );
        paint.color = state.color.withValues(alpha: state.opacity);
        paint.blendMode = particle.blendMode;
        canvas.drawImageRect(particle.image!, src, dst, paint);
      } else {
        paint.color = state.color.withValues(alpha: state.opacity);
        paint.blendMode = particle.blendMode;
        canvas.drawCircle(state.position, state.size.width / 2, paint);
      }

      canvas.restore();
    }

    if (debugMode) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final shapePath = shape.getShapePath();
      canvas.drawPath(shapePath, paint);
    }
  }

  void dispose() {
    for (final particle in particles) {
      particle.dispose();
    }

    particles.clear();
  }
}
