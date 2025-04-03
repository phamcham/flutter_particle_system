abstract class Lerpable<T> {
  const Lerpable();

  T valueAt(double t);

  factory Lerpable.constant(T value) = ConstantValue;
  factory Lerpable.betweenTwoConstants(T min, T max) =
      RandomBetweenTwoContaints;
  factory Lerpable.values(List<T> values, {List<double>? weights}) =
      RandomValues;
}

class ConstantValue<T> extends Lerpable<T> {
  final T value;

  const ConstantValue(this.value);

  @override
  T valueAt(double t) => value;
}

class RandomBetweenTwoContaints<T> extends Lerpable<T> {
  final T min;
  final T max;

  const RandomBetweenTwoContaints(this.min, this.max);

  @override
  T valueAt(double t) {
    return (min as dynamic) + ((max as dynamic) - (min as dynamic)) * t;
  }
}

class RandomValues<T> extends Lerpable<T> {
  final List<T> values;
  final List<double>? weights;

  RandomValues(this.values, {this.weights});

  @override
  T valueAt(double t) {
    if (weights == null) {
      final index =
          (t * (values.length - 1)).clamp(0, values.length - 1).toInt();
      return values[index];
    }

    final totalWeight = weights!.reduce((a, b) => a + b);
    final targetWeight = t * totalWeight;
    double cumulativeWeight = 0;

    for (int i = 0; i < values.length; i++) {
      cumulativeWeight += weights![i];
      if (targetWeight <= cumulativeWeight) {
        return values[i];
      }
    }

    return values.last;
  }
}
