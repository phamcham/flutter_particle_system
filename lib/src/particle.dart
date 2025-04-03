import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import 'components/texture_loader.dart';

class ParticleState {
  vmath.Vector2 position;
  vmath.Quaternion rotation;

  /// vận tốc lẫn hướng của nó
  vmath.Vector2 velocity;

  double scale;
  Color color;
  Size size;
  double opacity;

  ParticleState({
    required this.position,
    required this.rotation,
    required this.velocity,
    required this.scale,
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

  bool isDead;
  bool _disposed = false;

  TextureLoader? texture;

  factory Particle({
    required vmath.Vector2 position,
    required vmath.Vector2 velocity,
    double scale = 1,
    vmath.Quaternion? rotation,
    Color color = Colors.white,
    BlendMode blendMode = BlendMode.srcOver,
    required Size size,
    double opacity = 1,
    required double lifetime,
    required TextureLoader? texture,
  }) {
    rotation ??= vmath.Quaternion.identity();

    return Particle._(
      id: _getAutoIncrementId(),
      initial: ParticleState(
        position: position,
        rotation: rotation,
        velocity: velocity,
        scale: scale,
        color: color,
        size: size,
        opacity: opacity,
      ),
      current: ParticleState(
        position: position,
        rotation: rotation,
        velocity: velocity,
        scale: scale,
        color: color,
        size: size,
        opacity: opacity,
      ),
      blendMode: blendMode,
      lifetime: lifetime,
      age: 0,
      isDead: false,
      texture: texture,
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
    required this.texture,
  });

  void setImage(ui.Image image) {}

  void dispose() {
    if (_disposed) return;
    _disposed = true;
  }
}

int _currentIncrementId = 5112;
int _getAutoIncrementId() => _currentIncrementId++;
