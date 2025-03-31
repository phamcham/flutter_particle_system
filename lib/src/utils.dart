import 'package:flutter/material.dart';

class FixedTweenSequence<T> extends TweenSequence<T> {
  FixedTweenSequence(
    List<T> values, {
    List<double>? weights,
    required Animatable<T> Function(T value) getAnimatable,
  }) : super(
         getItems(
           values: values,
           weights: weights,
           getAnimatable: getAnimatable,
         ),
       );

  static List<TweenSequenceItem<T>> getItems<T>({
    required List<T> values,
    List<double>? weights,
    required Animatable<T> Function(T value) getAnimatable,
  }) {
    assert(weights == null || values.length == weights.length);

    List<TweenSequenceItem<T>> items = [];
    for (int i = 0; i < values.length; i++) {
      items.add(
        TweenSequenceItem<T>(
          weight: weights == null ? 1 : weights[i],
          tween: getAnimatable(values[i]),
        ),
      );
    }

    return items;
  }
}

class FixedColorTweenSequence extends FixedTweenSequence<Color?> {
  FixedColorTweenSequence(super.values, {super.weights})
    : super(getAnimatable: (value) => ColorTween(begin: value, end: value));
}
