class Value2<T> {
  T first;
  T second;

  Value2(this.first, this.second);

  Value2<T> operator +(Value2<T> other) {
    return Value2(
      (first as dynamic) + (other.first as dynamic),
      (second as dynamic) + (other.second as dynamic),
    );
  }

  Value2<T> operator -(Value2<T> other) {
    return Value2(
      (first as dynamic) - (other.first as dynamic),
      (second as dynamic) - (other.second as dynamic),
    );
  }

  Value2<T> operator *(dynamic other) {
    if (other is Value2<T>) {
      return Value2(
        (first as dynamic) * (other.first as dynamic),
        (second as dynamic) * (other.second as dynamic),
      );
    } else if (other is num) {
      return Value2((first as dynamic) * other, (second as dynamic) * other);
    }

    return this;
  }
}

class Value3<T> {
  T first;
  T second;
  T third;

  Value3(this.first, this.second, this.third);

  Value3<T> operator +(Value3<T> other) {
    return Value3(
      (first as dynamic) + (other.first as dynamic),
      (second as dynamic) + (other.second as dynamic),
      (third as dynamic) + (other.third as dynamic),
    );
  }

  Value3<T> operator -(Value3<T> other) {
    return Value3(
      (first as dynamic) - (other.first as dynamic),
      (second as dynamic) - (other.second as dynamic),
      (third as dynamic) - (other.third as dynamic),
    );
  }

  Value3<T> operator *(dynamic other) {
    if (other is Value3<T>) {
      return Value3(
        (first as dynamic) * (other.first as dynamic),
        (second as dynamic) * (other.second as dynamic),
        (third as dynamic) * (other.third as dynamic),
      );
    } else if (other is num) {
      return Value3(
        (first as dynamic) * other,
        (second as dynamic) * other,
        (third as dynamic) * other,
      );
    }

    return this;
  }
}
