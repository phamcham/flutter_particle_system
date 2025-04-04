import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

// import 'components/value_range.dart';
import 'components/min_max_curve.dart';
import 'modules/angular_velocity_over_lifetime_module.dart';
import 'modules/color_over_lifetime_module.dart';
import 'modules/main_module.dart';
import 'modules/noise_module.dart';
import 'modules/opacity_over_lifetime_module.dart';
import 'modules/scale_over_lifetime_module.dart';
import 'modules/texture_sheet_module.dart';
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
  /// các giá trị sẽ được khởi tạo một lần với mỗi particle
  final MainModule initial;

  /// vận tốc này sẽ được cộng với vận tốc ban đầu
  VelocityOverLifetimeModule? velocityOverLifetime;

  /// Unity là SizeOverLifetime (thực chất là scale)
  ScaleOverLifetimeModule? scaleOverLifetime;
  // AngularVelocityOverLifetimeModule? angularVelocityOverLifetime;
  OpacityOverLifetimeModule? opacityOverLifetime;
  ColorOverLifetimeModule? colorOverLifetime;
  NoiseModule? noiseMovement;
  TextureSheetModule? textureSheet;

  double _timeSinceLastEmission = 0;
  double _systemElapsedTime = 0;
  bool _playing = false;
  bool _debugBoundParticles = false;
  bool _debugBoundShape = false;
  bool _disposed = false;

  ParticleSystem({
    required this.duration,
    required this.looping,
    required bool autoPlay,
    required this.initial,
    this.colorOverLifetime,
    this.scaleOverLifetime,
    this.velocityOverLifetime,
    // this.angularVelocityOverLifetime,
    this.opacityOverLifetime,
    this.noiseMovement,
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
      particlesToEmit = (initial.rateOverTime * _timeSinceLastEmission).floor();
      _timeSinceLastEmission -= particlesToEmit / initial.rateOverTime;
    }

    for (
      int i = 0;
      i < particlesToEmit && particles.length < initial.maxParticles;
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

      // particle.current.angularVelocity = _applyAngularVelocityAtProgress(
      //   particle.initial.velocity,
      //   particle.current.rotation,
      //   lifeProgress,
      // );

      particle.current.rotation = _applyRotationAtProgress(
        particle.current.rotation,
        particle.current.angularVelocity,
        deltaTime,
      );
    }
  }

  vmath.Vector2 _applyPositionAtProgress(
    vmath.Vector2 currentPosition,
    vmath.Vector2 currentVelocity,
    double deltaTime,
  ) {
    final position = currentPosition + currentVelocity * deltaTime;

    if (noiseMovement != null) {
      //
    }

    return position;
  }

  Color _applyColorAtProgress(Color color, double lifeProgress) {
    if (colorOverLifetime != null) {
      final progressColor = colorOverLifetime!.color.evaluate(lifeProgress);
      color = Color.alphaBlend(color, progressColor);
    }
    return color;
  }

  double _applyOpacityAtProgress(double opacity, double lifeProgress) {
    final module = opacityOverLifetime;
    if (module == null) return opacity;

    final progressOpacity = module.opacity.evaluate(lifeProgress);
    opacity = opacity * progressOpacity;

    return opacity;
  }

  double _applyScaleAtProgress(double initialScale, double lifeProgress) {
    if (scaleOverLifetime != null) {
      final progressScale = scaleOverLifetime!.scale.evaluate(lifeProgress);
      initialScale *= progressScale;
    }

    return initialScale;
  }

  /// vận tốc cũng bị chi phối bởi noise
  vmath.Vector2 _applyVelocityAtProgress(
    vmath.Vector2 currentVelocity,
    vmath.Quaternion currentRotation,
    double lifeProgress,
  ) {
    final module = velocityOverLifetime;
    if (module == null) {
      return currentVelocity;
    }

    vmath.Vector2 velocity = currentVelocity;
    final progressVelocity = velocityOverLifetime!.evaluate(lifeProgress);

    if (!velocityOverLifetime!.inWorldSpace) {
      // Nếu là local space, ta xoay progressVelocity theo currentRotation
      final rotationMatrix = vmath.Matrix3.rotationZ(currentRotation.z);
      final transformedVelocity = rotationMatrix.transform(
        vmath.Vector3(progressVelocity.x, progressVelocity.y, 0),
      );

      velocity += transformedVelocity.xy;
    }

    return velocity + progressVelocity.xy;
  }

  // vmath.Vector3 _applyAngularVelocityAtProgress(
  //   vmath.Vector3 currentAngularVelocity,
  //   double lifeProgress,
  // ) {
  //   final module = angularVelocityOverLifetime;
  //   if (module == null) return currentAngularVelocity;

  //   final angularVelocity = currentAngularVelocity;
  //   if (module.angularVelocityX.mode == ParticleSystemCurveMode.curve) {
  //     angularVelocity.x = module.angularVelocityX.evaluate(lifeProgress);
  //   }

  //   if (module.angularVelocityY.mode == ParticleSystemCurveMode.curve) {
  //     angularVelocity.y = module.angularVelocityY.evaluate(lifeProgress);
  //   }

  //   if (module.angularVelocityZ.mode == ParticleSystemCurveMode.curve) {
  //     angularVelocity.z = module.angularVelocityZ.evaluate(lifeProgress);
  //   }

  //   return angularVelocity;
  // }

  vmath.Quaternion _applyRotationAtProgress(
    vmath.Quaternion currentRotation,
    vmath.Vector3 currentAngularVelocity,
    double deltaTime,
  ) {
    if (currentAngularVelocity == vmath.Vector3.zero()) {
      return currentRotation;
    }

    final deltaRotation = vmath.Quaternion.axisAngle(
      currentAngularVelocity.normalized(),
      currentAngularVelocity.length * deltaTime,
    );

    return deltaRotation * currentRotation;
  }

  void _emitParticle() {
    final spawnPosition = initial.shape.getSpawnPosition();
    final direction = initial.shape.getDirection();

    final velocity = direction * initial.speed.evaluate(_randomDouble());

    /// vector3 random từng số
    final angularVelocity = _randomVector3(initial.angularVelocity);
    final lifetime = initial.lifetime.randomOnEvaluate();
    final size = initial.size.randomOnEvaluate();
    final color = initial.color.randomOnEvaluate();
    final rotation = initial.rotation.randomOnEvaluate();
    final scale = initial.scale.randomOnEvaluate();
    final opacity = initial.opacity.randomOnEvaluate();
    final texture = textureSheet?.random();

    final particle = Particle(
      position: spawnPosition,
      velocity: velocity,
      angularVelocity: angularVelocity,
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

  double _randomDouble([Random? rnd]) {
    final t = (rnd ?? Random()).nextInt(100_001) / 100_000;
    return t;
  }

  vmath.Vector3 _randomVector3(
    MinMaxCurve<vmath.Vector3> minMax, [
    Random? rnd,
  ]) {
    final min = minMax.constantMin;
    final max = minMax.constantMax;

    return vmath.Vector3(
      min.x + (_randomDouble(rnd) * (max.x - min.x)),
      min.y + (_randomDouble(rnd) * (max.y - min.y)),
      min.z + (_randomDouble(rnd) * (max.z - min.z)),
    );
  }

  void render(Canvas canvas) {
    if (_disposed) return;

    for (var particle in particles) {
      final paint = Paint();
      paint.isAntiAlias = textureSheet?.isAntiAlias ?? true;
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

      final shapePath = initial.shape.getShapePath();
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
      for (final texture in textureSheet!.textureSheet) {
        texture.dispose();
      }
    }

    particles.clear();
  }
}
