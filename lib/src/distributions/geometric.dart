import 'dart:math' as math;

import '../errors.dart';
import 'discrete_distribution.dart';

/// Geometric distribution with success probability [p].
///
/// Models the number of failures before the first success.
/// PMF: P(k) = (1-p)^k * p  for k = 0, 1, 2, ...
class Geometric extends DiscreteDistribution {
  /// Creates a Geometric distribution with success probability [p].
  ///
  /// Throws [InvalidInputException] if p not in (0, 1].
  Geometric({required this.p}) {
    if (p <= 0 || p > 1) {
      throw InvalidInputException('Geometric: p must be in (0, 1], got p=$p');
    }
  }

  /// Fits a Geometric distribution to [data] using MLE.
  ///
  /// MLE: p = 1 / (1 + mean(data)).
  factory Geometric.fit(List<int> data) {
    if (data.isEmpty) {
      throw const EmptyDataException('Geometric.fit requires non-empty data');
    }
    for (final x in data) {
      if (x < 0) {
        throw InvalidInputException(
          'Geometric.fit requires non-negative values, got $x',
        );
      }
    }
    final sum = data.fold(0, (a, b) => a + b);
    final m = sum / data.length;
    return Geometric(p: 1.0 / (1.0 + m));
  }

  /// Success probability (0 < p <= 1).
  final double p;

  @override
  String get name => 'Geometric';

  @override
  int get numParams => 1;

  @override
  double get distMean => (1.0 - p) / p;

  @override
  double get distVariance => (1.0 - p) / (p * p);

  @override
  double pmf(int k) {
    if (k < 0) return 0.0;
    return math.pow(1.0 - p, k).toDouble() * p;
  }

  @override
  double logpmf(int k) {
    if (k < 0) return double.negativeInfinity;
    return k * math.log(1.0 - p) + math.log(p);
  }

  @override
  double cdf(int k) {
    if (k < 0) return 0.0;
    return 1.0 - math.pow(1.0 - p, k + 1).toDouble();
  }

  @override
  int inverseCdf(double p) {
    if (p <= 0) return 0;
    if (p >= 1) return (1 / this.p * 100).ceil();
    // Closed form: ceil(ln(1-p) / ln(1-this.p)) - 1
    return (math.log(1.0 - p) / math.log(1.0 - this.p)).ceil() - 1;
  }

  @override
  String toString() => 'Geometric(p=$p)';
}
