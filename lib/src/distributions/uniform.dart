import '../errors.dart';
import 'distribution.dart';

/// Continuous uniform distribution on [min, max].
class Uniform extends Distribution {
  /// Creates a Uniform distribution on [[min], [max]].
  ///
  /// Throws [InvalidInputException] if [min] ≥ [max].
  Uniform({required this.min, required this.max}) {
    if (min >= max) {
      throw InvalidInputException(
        'Uniform: min must be < max, got min=$min, max=$max',
      );
    }
  }

  /// Fits a Uniform distribution to [data].
  ///
  /// Uses min and max of the data. Requires at least 2 distinct values.
  factory Uniform.fit(List<num> data) {
    if (data.length < 2) {
      throw const EmptyDataException(
        'Uniform.fit requires at least 2 data points',
      );
    }
    var lo = data[0].toDouble();
    var hi = data[0].toDouble();
    for (final x in data) {
      final v = x.toDouble();
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (lo == hi) {
      throw const EmptyDataException(
        'Uniform.fit requires at least 2 distinct values',
      );
    }
    return Uniform(min: lo, max: hi);
  }

  /// Lower bound.
  final double min;

  /// Upper bound.
  final double max;

  @override
  String get name => 'Uniform';

  @override
  int get numParams => 2;

  @override
  double get distMean => (min + max) / 2.0;

  @override
  double get distVariance {
    final range = max - min;
    return range * range / 12.0;
  }

  @override
  double pdf(double x) {
    if (x < min || x > max) return 0.0;
    return 1.0 / (max - min);
  }

  @override
  double cdf(double x) {
    if (x < min) return 0.0;
    if (x > max) return 1.0;
    return (x - min) / (max - min);
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    return min + p * (max - min);
  }

  @override
  String toString() => 'Uniform(min=$min, max=$max)';
}
