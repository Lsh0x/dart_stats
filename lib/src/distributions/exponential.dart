import 'dart:math' as math;

import '../descriptive/average.dart';
import '../errors.dart';
import 'distribution.dart';

/// Exponential distribution with rate parameter [lambda].
class Exponential extends Distribution {
  /// Creates an Exponential distribution with rate [lambda].
  ///
  /// Throws [InvalidInputException] if [lambda] ≤ 0.
  Exponential({required this.lambda}) {
    if (lambda <= 0) {
      throw InvalidInputException(
        'Exponential: lambda must be positive, got lambda=$lambda',
      );
    }
  }

  /// Fits an Exponential distribution to [data] using MLE.
  ///
  /// MLE: lambda = 1 / mean(data). All values must be > 0.
  factory Exponential.fit(List<num> data) {
    if (data.isEmpty) {
      throw const EmptyDataException(
        'Exponential.fit requires non-empty data',
      );
    }
    for (final x in data) {
      if (x.toDouble() <= 0) {
        throw InvalidInputException(
          'Exponential.fit requires all values > 0, got $x',
        );
      }
    }
    return Exponential(lambda: 1.0 / mean(data));
  }

  /// Rate parameter.
  final double lambda;

  @override
  String get name => 'Exponential';

  @override
  int get numParams => 1;

  @override
  double get distMean => 1.0 / lambda;

  @override
  double get distVariance => 1.0 / (lambda * lambda);

  @override
  double pdf(double x) {
    if (x < 0) return 0.0;
    return lambda * math.exp(-lambda * x);
  }

  @override
  double logpdf(double x) {
    if (x < 0) return double.negativeInfinity;
    return math.log(lambda) - lambda * x;
  }

  @override
  double cdf(double x) {
    if (x < 0) return 0.0;
    return 1.0 - math.exp(-lambda * x);
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException(
        'inverseCdf requires 0 < p < 1, got p=$p',
      );
    }
    return -math.log(1.0 - p) / lambda;
  }

  @override
  String toString() => 'Exponential(lambda=$lambda)';
}
