import 'dart:math';

import 'package:flutter/material.dart';

class MinMaxCurve<T> {
  final T constant;
  final T constantMin;
  final T constantMax;
  final Curve curve;
  final ParticleSystemCurveMode mode;

  MinMaxCurve({
    required this.constant,
    required this.constantMin,
    required this.constantMax,
    required this.curve,
    required this.mode,
  });

  factory MinMaxCurve.constant(T value) {
    return MinMaxCurve(
      constant: value,
      constantMin: value,
      constantMax: value,
      curve: Curves.linear,
      mode: ParticleSystemCurveMode.constant,
    );
  }

  factory MinMaxCurve.linearTwoConstants(T min, T max) {
    return MinMaxCurve(
      constant: min,
      constantMin: min,
      constantMax: max,
      curve: Curves.linear,
      mode: ParticleSystemCurveMode.curve,
    );
  }

  factory MinMaxCurve.curve(T min, T max, Curve curve) {
    return MinMaxCurve(
      constant: min,
      constantMin: min,
      constantMax: max,
      curve: curve,
      mode: ParticleSystemCurveMode.curve,
    );
  }

  T evaluate(double time) {
    if (mode == ParticleSystemCurveMode.constant) {
      return constant;
    }

    final t = time.clamp(0.0, 1.0);
    final curveValue = curve.transform(t);

    return (constantMin as dynamic) +
        ((constantMax as dynamic) - (constantMin as dynamic)) * curveValue;
  }

  T randomOnEvaluate([Random? rnd]) {
    final t = (rnd ?? Random()).nextInt(100_001) / 100_000;
    return evaluate(t);
  }
}

enum ParticleSystemCurveMode { constant, curve }
