import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ParticleState {
  Offset position;
  double rotation;
  Offset velocity;
  double scale;
  double rotationVelocity;
  Color color;
  Size size;
  double opacity;

  ParticleState({
    required this.position,
    required this.rotation,
    required this.velocity,
    required this.scale,
    required this.rotationVelocity,
    required this.color,
    required this.size,
    required this.opacity,
  });
}

class Particle {
  final int id;

  final ParticleState initial;
  ParticleState current;

  BlendMode blendMode;

  double lifetime;
  double age;

  ui.Image? image;

  bool isDead;
  bool _disposed = false;

  factory Particle({
    required Offset position,
    required Offset velocity,
    double scale = 1,
    double rotateVelocity = 0,
    double rotation = 0,
    Color color = Colors.white,
    BlendMode blendMode = BlendMode.srcOver,
    required Size size,
    double opacity = 1,
    required double lifetime,
  }) {
    return Particle._(
      id: _getAutoIncrementId(),
      initial: ParticleState(
        position: position,
        rotation: rotation,
        velocity: velocity,
        scale: scale,
        rotationVelocity: rotateVelocity,
        color: color,
        size: size,
        opacity: opacity,
      ),
      current: ParticleState(
        position: position,
        rotation: rotation,
        velocity: velocity,
        scale: scale,
        rotationVelocity: rotateVelocity,
        color: color,
        size: size,
        opacity: opacity,
      ),
      blendMode: blendMode,
      lifetime: lifetime,
      age: 0,
      isDead: false,
    );
  }

  Particle._({
    required this.id,
    required this.initial,
    required this.current,
    required this.blendMode,
    required this.lifetime,
    required this.age,
    required this.isDead,
  });

  void dispose() {
    if (_disposed) return;
    _disposed = true;

    image?.dispose();
  }
}

int _currentIncrementId = 5112;
int _getAutoIncrementId() => _currentIncrementId++;
