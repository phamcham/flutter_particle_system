import 'dart:math';

import 'package:flutter/material.dart';

import 'components/texture_loader.dart';
import 'components/particle_system_shape.dart';
// import 'components/value_range.dart';
import 'particle.dart';

class ParticleSystem {
  List<Particle> particles = [];

  double duration;
  bool looping;

  // Lerpable<double> startDelay;
  final Animatable<double> startLifetime;
  final Animatable<double> startVelocity;
  Animatable<double>? speedOverLifetime;
  final Animatable<double> startRotationVelocity;
  Animatable<double>? rotationSpeedOverLifetime;
  final Animatable<double> startSizeX;
  Animatable<double>? sizeXOverLifetime;
  final Animatable<double> startSizeY;
  Animatable<double>? sizeYOverLifetime;
  final Animatable<double> startRotation;
  final Animatable<double> startScale;
  final Animatable<double> startOpacity;
  Animatable<double>? opacityOverLifetime;
  final Animatable<Color?> startColor;
  Animatable<Color?>? colorOverLifetime;
  final List<TextureLoader>? textureSheet;

  int maxParticles;

  /// Số particle được emit mỗi giây
  int rateOverTime;

  ParticleSystemShape shape;

  double _timeSinceLastEmission = 0;
  double _systemElapsedTime = 0;
  bool _playing = false;
  bool _debugBoundParticles = false;
  bool _debugBoundShape = false;

  final Random _random = Random();

  ParticleSystem({
    required this.duration,
    required this.looping,
    required bool autoPlay,
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
    this.textureSheet,
  }) : _playing = autoPlay {
    if (_playing) play();
  }

  void play() {
    _playing = true;
  }

  void stop() {
    _playing = false;
  }

  void clear() {
    _clearParticles(particles);
  }

  void reset() {
    _clearParticles(particles);
    _timeSinceLastEmission = 0;
    _systemElapsedTime = 0;
  }

  void _clearParticles(List<Particle> clearedParticles) {
    for (var particle in [...clearedParticles]) {
      particle.dispose();
      particles.removeWhere((e) => e.id == particle.id);
    }
  }

  void setDebugBoundParticles(bool active) {
    _debugBoundParticles = active;
  }

  void setDebugBoundShape(bool active) {
    _debugBoundShape = active;
  }

  void update(double deltaTime) {
    if (!_playing) return;

    /// giới hạn để tránh brust
    deltaTime = min(deltaTime, 0.05);

    _timeSinceLastEmission += deltaTime;
    _systemElapsedTime += deltaTime;

    // print(_timeSinceLastEmission);

    // Xóa các particle đã hết thời gian sống
    _clearParticles(particles.where((p) => p.age >= p.lifetime).toList());

    // Tính số particle cần phát
    int particlesToEmit = 0;
    if (_systemElapsedTime < duration || looping) {
      /// có thể emit thêm particle
      particlesToEmit = (rateOverTime * _timeSinceLastEmission).floor();
      _timeSinceLastEmission -= particlesToEmit / rateOverTime;
    }

    for (
      int i = 0;
      i < particlesToEmit && particles.length < maxParticles;
      i++
    ) {
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

      particle.current.color = _applyColorAtProgress(
        particle.initial.color,
        lifeProgress,
      );

      particle.current.opacity = _applyOpacityAtProgress(
        particle.initial.opacity,
        lifeProgress,
      );

      particle.current.size = _applySizeAtProgress(
        particle.initial.size,
        lifeProgress,
      );

      particle.current.velocity = _applyVelocityAtProgress(
        particle.initial.velocity,
        lifeProgress,
      );

      particle.current.rotationVelocity = _applyRotationVelocityAtProgress(
        particle.initial.rotationVelocity,
        lifeProgress,
      );
    }
  }

  Color _applyColorAtProgress(Color color, double lifeProgress) {
    if (colorOverLifetime != null) {
      final progressColor =
          colorOverLifetime!.transform(lifeProgress) ?? Colors.transparent;
      color = Color.alphaBlend(color, progressColor);
    }
    return color;
  }

  double _applyOpacityAtProgress(double opacity, double lifeProgress) {
    if (opacityOverLifetime != null) {
      final progressOpacity = opacityOverLifetime!.transform(lifeProgress);
      opacity = opacity * progressOpacity;
    }

    return opacity;
  }

  Size _applySizeAtProgress(Size size, double lifeProgress) {
    if (sizeXOverLifetime != null) {
      final progressSizeX = sizeXOverLifetime!.transform(lifeProgress);
      size = Size(size.width * progressSizeX, size.height);
    }

    if (sizeYOverLifetime != null) {
      final progressSizeY = sizeYOverLifetime!.transform(lifeProgress);
      size = Size(size.width, size.height * progressSizeY);
    }

    return size;
  }

  Offset _applyVelocityAtProgress(Offset velocity, double lifeProgress) {
    if (speedOverLifetime != null) {
      final progressSpeed = speedOverLifetime!.transform(lifeProgress);
      velocity = velocity * progressSpeed;
    }

    return velocity;
  }

  double _applyRotationVelocityAtProgress(
    double rotationVelocity,
    double lifeProgress,
  ) {
    if (rotationSpeedOverLifetime != null) {
      final progressSpeed = rotationSpeedOverLifetime!.transform(lifeProgress);
      rotationVelocity = rotationVelocity * progressSpeed;
    }

    return rotationVelocity;
  }

  void _emitParticle() {
    final spawnPosition = shape.getSpawnPosition();
    final direction = shape.getDirection();

    final velocity = direction * _getRandomValue(startVelocity);
    final lifetime = _getRandomValue(startLifetime);
    final size = Size(_getRandomValue(startSizeX), _getRandomValue(startSizeY));
    final color = _getRandomValue(startColor) ?? Colors.white;
    final rotation = _getRandomValue(startRotation);
    final scale = _getRandomValue(startScale);
    final opacity = _getRandomValue(startOpacity);
    final rotationVelocity = _getRandomValue(startRotationVelocity);
    final texture = _getRandomTexture();

    final particle = Particle(
      position: spawnPosition,
      velocity: velocity,
      scale: scale,
      size: size,
      lifetime: lifetime,
      color: color,
      rotation: rotation,
      rotateVelocity: rotationVelocity,
      opacity: opacity,
      texture: texture,
    );

    particles.add(particle);
  }

  T _getRandomValue<T>(Animatable<T> lerper) {
    return lerper.transform(_random.nextDouble());
  }

  TextureLoader? _getRandomTexture() {
    final sheet = textureSheet;
    if (sheet == null) return null;
    assert(sheet.isNotEmpty);
    return sheet[_random.nextInt(sheet.length)];
  }

  void render(Canvas canvas) {
    for (var particle in particles) {
      final paint = Paint();
      // TODO: thêm rotation
      // canvas.translate(particle.position.dx, particle.position.dy);
      // canvas.rotate(particle.rotation);

      final state = particle.current;

      canvas.save();
      canvas.translate(state.position.dx, state.position.dy);
      canvas.scale(particle.current.scale);

      paint.color = state.color.withValues(alpha: state.opacity);
      paint.blendMode = particle.blendMode;

      final texture = particle.texture?.result;
      if (texture != null) {
        final src = Rect.fromLTWH(
          0,
          0,
          texture.width.toDouble(),
          texture.height.toDouble(),
        );
        final dst = Rect.fromCenter(
          center: Offset.zero,
          width: state.size.width,
          height: state.size.height,
        );

        canvas.drawImageRect(texture, src, dst, paint);
      } else {
        canvas.drawCircle(Offset.zero, state.size.width / 2, paint);
      }

      canvas.restore();

      if (_debugBoundParticles) {
        final debugPaint =
            Paint()
              ..color = Colors.green
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0;

        canvas.drawRect(
          Rect.fromCenter(
            center: state.position,
            width: state.size.width,
            height: state.size.height,
          ),
          debugPaint,
        );
      }
    }

    if (_debugBoundShape) {
      final debugPaint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;

      final shapePath = shape.getShapePath();
      canvas.drawPath(shapePath, debugPaint);
    }
  }

  void dispose() {
    for (final particle in particles) {
      particle.dispose();
    }

    if (textureSheet != null) {
      for (final texture in textureSheet!) {
        texture.dispose();
      }
    }

    particles.clear();
  }
}
