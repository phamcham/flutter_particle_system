import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import 'components/lerpable.dart';
import 'components/texture_loader.dart';
import 'components/particle_system_shape.dart';
// import 'components/value_range.dart';
import 'modules/velocity_over_lifetime_module.dart';
import 'particle.dart';

/// Các giá trị start là các giá trị ngẫu nhiên một lần.
/// Các giá trị overlifetime là các giá trị liên tục theo t.
/// Trong flutter position, scale với trục z không có tác dụng, trục z chỉ
/// được sử dụng trong rotation3d
class ParticleSystem {
  List<Particle> particles = [];

  double duration;
  bool looping;

  // Lerpable<double> startDelay;
  final Lerpable<double> startLifetime;
  final Lerpable<double> startSpeed;
  // Lerpable<double>? speedOverLifetime;
  final Lerpable<Size> startSize;
  final Lerpable<double> startScale;
  final Lerpable<double> startOpacity;
  final Lerpable<Color?> startColor;
  final Lerpable<vmath.Quaternion> startRotation;

  /// vận tốc này sẽ được cộng với vận tốc ban đầu
  VelocityOverLifetimeModule? velocityOverLifetime;

  /// Unity là SizeOverLifetime (thực chất là scale)
  Lerpable<double>? scaleOverLifetime;

  /// Unity là RotationOverLifetime (thực chất là velocity).
  /// Tốc độ xoay mỗi giây của mỗi particle.
  /// Hướng thể hiện trục xoay và độ lớn thể hiện vận tốc
  Lerpable<vmath.Vector3>? angularVelocityOverLifetime;
  Lerpable<double>? opacityOverLifetime;
  Lerpable<Color?>? colorOverLifetime;

  /// textures
  final List<TextureLoader>? textureSheet;

  int maxParticles;

  /// Số particle được emit mỗi giây
  int rateOverTime;

  bool isAntiAlias;

  ParticleSystemShape shape;

  double _timeSinceLastEmission = 0;
  double _systemElapsedTime = 0;
  bool _playing = false;
  bool _debugBoundParticles = false;
  bool _debugBoundShape = false;
  bool _disposed = false;

  final Random _random = Random();

  ParticleSystem({
    required this.duration,
    required this.looping,
    required bool autoPlay,
    // required this.startDelay,
    required this.startLifetime,
    required this.startSpeed,
    required this.startRotation,
    required this.startScale,
    required this.startColor,
    required this.startOpacity,
    required this.startSize,
    this.angularVelocityOverLifetime,
    this.colorOverLifetime,
    this.opacityOverLifetime,
    required this.maxParticles,
    required this.rateOverTime,
    required this.shape,
    this.textureSheet,

    /// làm mịn ảnh, tắt nếu dùng các ảnh siêu nhỏ mà sắc nét
    this.isAntiAlias = false,
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
    if (_disposed) return;

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
      particle.age += deltaTime;

      // Cập nhật vị trí
      particle.current.position = _applyPositionAtProgress(
        particle.current.position,
        particle.current.velocity,
        deltaTime,
      );

      particle.current.color = _applyColorAtProgress(
        particle.initial.color,
        lifeProgress,
      );

      particle.current.opacity = _applyOpacityAtProgress(
        particle.initial.opacity,
        lifeProgress,
      );

      particle.current.scale = _applyScaleAtProgress(
        particle.initial.scale,
        lifeProgress,
      );

      particle.current.velocity = _applyVelocityAtProgress(
        particle.initial.velocity,
        particle.current.rotation,
        lifeProgress,
      );

      particle.current.rotation = _applyRotationAtProgress(
        particle.current.rotation,
        lifeProgress,
        deltaTime,
      );
    }
  }

  vmath.Vector2 _applyPositionAtProgress(
    vmath.Vector2 currentPosition,
    vmath.Vector2 currentVelocity,
    double deltaTime,
  ) {
    return currentPosition + currentVelocity * deltaTime;
  }

  Color _applyColorAtProgress(Color color, double lifeProgress) {
    if (colorOverLifetime != null) {
      final progressColor =
          colorOverLifetime!.valueAt(lifeProgress) ?? Colors.transparent;
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

  double _applyScaleAtProgress(double initialScale, double lifeProgress) {
    if (scaleOverLifetime != null) {
      final progressScale = scaleOverLifetime!.valueAt(lifeProgress);
      initialScale *= progressScale;
    }

    return initialScale;
  }

  vmath.Vector2 _applyVelocityAtProgress(
    vmath.Vector2 initialVelocity,
    vmath.Quaternion currentRotation,
    double lifeProgress,
  ) {
    if (velocityOverLifetime != null) {
      final progressVelocity = velocityOverLifetime!.linear.valueAt(
        lifeProgress,
      );

      if (!velocityOverLifetime!.inWorldSpace) {
        // Nếu là local space, ta xoay progressVelocity theo currentRotation
        final rotationMatrix = vmath.Matrix3.rotationZ(currentRotation.z);
        final transformedVelocity = rotationMatrix.transform(
          vmath.Vector3(progressVelocity.x, progressVelocity.y, 0),
        );

        initialVelocity += transformedVelocity.xy;
      } else {
        initialVelocity += progressVelocity.xy;
      }
    }

    return initialVelocity;
  }

  vmath.Quaternion _applyRotationAtProgress(
    vmath.Quaternion currentRotation,
    double lifeProgress,
    double deltaTime,
  ) {
    if (angularVelocityOverLifetime != null) {
      final progressRotationVelocity = angularVelocityOverLifetime!.valueAt(
        lifeProgress,
      );

      final deltaRotation = vmath.Quaternion.axisAngle(
        progressRotationVelocity.normalized(),
        progressRotationVelocity.length * deltaTime,
      );

      return deltaRotation * currentRotation;
    }

    return currentRotation;
  }

  void _emitParticle() {
    final spawnPosition = shape.getSpawnPosition();
    final direction = shape.getDirection();

    final velocity = direction * _getRandomValue(startSpeed);
    final lifetime = _getRandomValue(startLifetime);
    final size = _getRandomValue(startSize);
    final color = _getRandomValue(startColor) ?? Colors.white;
    final rotation = _getRandomValue(startRotation);
    final scale = _getRandomValue(startScale);
    final opacity = _getRandomValue(startOpacity);
    final texture = _getRandomTexture();

    // print(color);

    final particle = Particle(
      position: spawnPosition,
      velocity: velocity,
      scale: scale,
      size: size,
      lifetime: lifetime,
      color: color,
      rotation: vmath.Quaternion.euler(rotation.x, rotation.y, rotation.z),
      opacity: opacity,
      texture: texture,
    );

    particles.add(particle);
  }

  T _getRandomValue<T>(Lerpable<T> lerper) {
    return lerper.valueAt(_random.nextDouble());
  }

  TextureLoader? _getRandomTexture() {
    final sheet = textureSheet;
    if (sheet == null) return null;
    assert(sheet.isNotEmpty);
    return sheet[_random.nextInt(sheet.length)];
  }

  void render(Canvas canvas) {
    if (_disposed) return;

    for (var particle in particles) {
      final paint = Paint();
      paint.isAntiAlias = isAntiAlias;

      final state = particle.current;

      canvas.save();

      final rotateMatrix =
          Matrix4.identity()..setFromTranslationRotationScale(
            vmath.Vector3(state.position.x, state.position.y, 0),
            state.rotation,
            vmath.Vector3.all(state.scale),
          );
      canvas.transform(rotateMatrix.storage);

      final color = state.color.withValues(alpha: state.opacity);
      paint.color = color;
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

        paint.colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
        canvas.drawImageRect(texture, src, dst, paint);
      } else {
        paint.blendMode = particle.blendMode;
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
            center: Offset(state.position.x, state.position.y),
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
    if (_disposed) return;
    _disposed = true;

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
