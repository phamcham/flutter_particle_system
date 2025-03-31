import 'package:flutter/material.dart';

abstract class Lerpable<T> {
  final T Function(double t) _onLerp;

  const Lerpable({required T Function(double) onLerp}) : _onLerp = onLerp;

  T valueAt(double t) => _onLerp(t);
}

class NoLerpableValue<T> extends Lerpable<T> {
  final T value;
  NoLerpableValue(this.value) : super(onLerp: (_) => value);
}

abstract class ValueRange<T> extends Lerpable<T> {
  final T start;
  final T end;

  const ValueRange(
    this.start,
    this.end, {
    required super.onLerp,
  });
}

class FixedValueRange<T> extends Lerpable<T> {
  final List<T> values;

  const FixedValueRange(
    this.values, {
    required super.onLerp,
  });
}

class DoubleRange extends ValueRange<double> {
  DoubleRange(super.start, super.end)
      : super(
          onLerp: (t) {
            return start + (end - start) * t;
          },
        );
}

class IntRange extends ValueRange<int> {
  IntRange(super.start, super.end)
      : super(
          onLerp: (t) {
            return (start + (end - start) * t).toInt();
          },
        );
}

class ColorRange extends ValueRange<Color> {
  ColorRange(super.start, super.end)
      : super(
          onLerp: (t) {
            return Color.lerp(start, end, t) ?? start;
          },
        );
}

class ColorFixedRange extends FixedValueRange<Color> {
  ColorFixedRange(super.values)
      : assert(values.isNotEmpty),
        super(
          onLerp: (t) {
            final it = ((values.length - 1) * t).round();
            return values[it];
          },
        );
}
