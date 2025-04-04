import 'dart:math';

import 'package:flutter/material.dart';

class ColorOverLifetimeModule {
  final ColorOverLifetimeModuleGradient color;

  ColorOverLifetimeModule({required this.color});
}

class ColorOverLifetimeModuleGradient {
  final Map<double, Color> colors;
  final ColorOverLifetimeModuleGradientMode mode;

  ColorOverLifetimeModuleGradient._({required this.colors, required this.mode});

  factory ColorOverLifetimeModuleGradient({
    required List<Color> colors,
    required List<double> weights,
    required ColorOverLifetimeModuleGradientMode mode,
  }) {
    assert(colors.length == weights.length);

    Map<double, Color> map = {0: colors.first, 1: colors.last};

    for (int i = 0; i < colors.length; i++) {
      final weight = weights[i];
      final color = colors[i];

      map[weight] = color;
    }

    return ColorOverLifetimeModuleGradient._(colors: map, mode: mode);
  }

  factory ColorOverLifetimeModuleGradient.distribute(
    List<Color> colors, {
    ColorOverLifetimeModuleGradientMode mode =
        ColorOverLifetimeModuleGradientMode.fixed,
  }) {
    assert(colors.isNotEmpty);

    final weight = 1.0 / colors.length;
    return ColorOverLifetimeModuleGradient(
      colors: colors,
      weights: List.generate(colors.length, (i) => i * weight),
      mode: mode,
    );
  }

  Color evaluate(double time) {
    time = time.clamp(0.0, 1.0);

    int index = -1;
    final entries = colors.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    for (int i = 0; i < entries.length - 1; i++) {
      final key = entries[i].key;
      final nextKey = entries[i + 1].key;
      if (time >= key && time <= nextKey) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      return colors.values.first;
    }

    final key = entries[index].key;
    final nextKey = entries[index + 1].key;
    final value = entries[index].value;
    final nextValue = entries[index + 1].value;

    double t = (time - key) / (nextKey - key);

    switch (mode) {
      case ColorOverLifetimeModuleGradientMode.fixed:
        return value;
      case ColorOverLifetimeModuleGradientMode.blend:
        return _blendColors(value, nextValue, t);
      case ColorOverLifetimeModuleGradientMode.perceptualBlend:
        return _perceptualBlendColors(value, nextValue, t);
    }
  }

  Color randomOnEvaluate([Random? rnd]) {
    final t = (rnd ?? Random()).nextInt(100_001) / 100_000;
    return evaluate(t);
  }

  Color _blendColors(Color start, Color end, double t) {
    // Nội suy màu sắc đơn giản giữa hai màu (blend)
    int r = ((1 - t) * start.r + t * end.r).toInt();
    int g = ((1 - t) * start.g + t * end.g).toInt();
    int b = ((1 - t) * start.b + t * end.b).toInt();
    int a = ((1 - t) * start.a + t * end.a).toInt();
    return Color.fromARGB(a, r, g, b);
  }

  Color _perceptualBlendColors(Color start, Color end, double t) {
    // Dùng không gian màu HSL để nội suy màu sắc (perceptual blend)
    HSVColor startHSV = HSVColor.fromColor(start);
    HSVColor endHSV = HSVColor.fromColor(end);

    double a = (1 - t) * startHSV.alpha + t * endHSV.alpha;
    double h = (1 - t) * startHSV.hue + t * endHSV.hue;
    double s = (1 - t) * startHSV.saturation + t * endHSV.saturation;
    double v = (1 - t) * startHSV.value + t * endHSV.value;

    return HSVColor.fromAHSV(a, h, s, v).toColor();
  }
}

enum ColorOverLifetimeModuleGradientMode { fixed, blend, perceptualBlend }
