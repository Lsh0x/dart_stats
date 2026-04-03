import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'discrete_distribution.dart';

/// Poisson distribution with rate parameter [lambda].
///
/// PMF: P(k) = lambda^k * exp(-lambda) / k!
class Poisson extends DiscreteDistribution {
  /// Creates a Poisson distribution with rate [lambda].
  ///
  /// Throws [InvalidInputException] if [lambda] <= 0.
  Poisson({required this.lambda}) {
    if (lambda <= 0) {
      throw InvalidInputException(
        'Poisson: lambda must be positive, got lambda=$lambda',
      );
    }
  }

  /// Fits a Poisson distribution to [data] using MLE.
  ///
  /// MLE: lambda = mean(data).
  factory Poisson.fit(List<int> data) {
    if (data.isEmpty) {
      throw const EmptyDataException('Poisson.fit requires non-empty data');
    }
    for (final x in data) {
      if (x < 0) {
        throw InvalidInputException(
          'Poisson.fit requires non-negative values, got $x',
        );
      }
    }
    final sum = data.fold(0, (a, b) => a + b);
    return Poisson(lambda: sum / data.length);
  }

  /// Rate parameter (lambda > 0).
  final double lambda;

  @override
  String get name => 'Poisson';

  @override
  int get numParams => 1;

  @override
  double get distMean => lambda;

  @override
  double get distVariance => lambda;

  @override
  double pmf(int k) {
    if (k < 0) return 0.0;
    return math.exp(logpmf(k));
  }

  @override
  double logpmf(int k) {
    if (k < 0) return double.negativeInfinity;
    return k * math.log(lambda) - lambda - lnGamma(k + 1.0);
  }

  @override
  double cdf(int k) {
    if (k < 0) return 0.0;
    var sum = 0.0;
    for (var i = 0; i <= k; i++) {
      sum += pmf(i);
      if (sum >= 1.0) return 1.0;
    }
    return sum;
  }

  @override
  int inverseCdf(double p) {
    if (p <= 0) return 0;
    if (p >= 1) return (lambda * 100).ceil(); // practical upper bound
    var cumulative = 0.0;
    for (var k = 0; ; k++) {
      cumulative += pmf(k);
      if (cumulative >= p) return k;
      if (k > lambda * 100) return k; // safety
    }
  }

  @override
  String toString() => 'Poisson(lambda=$lambda)';
}
