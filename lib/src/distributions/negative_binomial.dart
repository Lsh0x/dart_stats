import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'discrete_distribution.dart';

/// Negative Binomial distribution with [r] successes and probability [p].
///
/// Models the number of failures before [r] successes.
/// PMF: P(k) = C(k+r-1, k) * p^r * (1-p)^k  for k = 0, 1, 2, ...
class NegativeBinomial extends DiscreteDistribution {
  /// Creates a Negative Binomial distribution.
  ///
  /// [r] is the number of successes (> 0), [p] is the success probability in (0, 1].
  NegativeBinomial({required this.r, required this.p}) {
    if (r <= 0) {
      throw InvalidInputException(
        'NegativeBinomial: r must be positive, got r=$r',
      );
    }
    if (p <= 0 || p > 1) {
      throw InvalidInputException(
        'NegativeBinomial: p must be in (0, 1], got p=$p',
      );
    }
  }

  /// Fits a Negative Binomial distribution to [data] using method of moments.
  ///
  /// Estimates r and p from sample mean and variance.
  factory NegativeBinomial.fit(List<int> data) {
    if (data.isEmpty) {
      throw const EmptyDataException(
        'NegativeBinomial.fit requires non-empty data',
      );
    }
    for (final x in data) {
      if (x < 0) {
        throw InvalidInputException(
          'NegativeBinomial.fit requires non-negative values, got $x',
        );
      }
    }

    final n = data.length;
    final sum = data.fold(0, (a, b) => a + b);
    final m = sum / n;

    var sumSq = 0.0;
    for (final x in data) {
      sumSq += (x - m) * (x - m);
    }
    final v = sumSq / (n - 1);

    if (v <= m) {
      // Variance must be > mean for NB; fallback
      return NegativeBinomial(r: 1, p: 1.0 / (1.0 + m));
    }

    // Method of moments: p = m/v, r = m*p/(1-p) = m^2/(v-m)
    final pEst = m / v;
    final rEst = (m * pEst / (1.0 - pEst)).round().clamp(1, 1000);

    return NegativeBinomial(r: rEst, p: pEst.clamp(0.001, 1.0));
  }

  /// Number of successes required.
  final int r;

  /// Success probability.
  final double p;

  @override
  String get name => 'NegativeBinomial';

  @override
  int get numParams => 2;

  @override
  double get distMean => r * (1.0 - p) / p;

  @override
  double get distVariance => r * (1.0 - p) / (p * p);

  @override
  double pmf(int k) {
    if (k < 0) return 0.0;
    return math.exp(logpmf(k));
  }

  @override
  double logpmf(int k) {
    if (k < 0) return double.negativeInfinity;
    // ln(C(k+r-1, k)) = lnGamma(k+r) - lnGamma(k+1) - lnGamma(r)
    return lnGamma(k + r.toDouble()) -
        lnGamma(k + 1.0) -
        lnGamma(r.toDouble()) +
        r * math.log(p) +
        k * math.log(1.0 - p);
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
    if (p >= 1) return (distMean * 100).ceil();
    var cumulative = 0.0;
    for (var k = 0; ; k++) {
      cumulative += pmf(k);
      if (cumulative >= p) return k;
      if (k > distMean * 100) return k;
    }
  }

  @override
  String toString() => 'NegativeBinomial(r=$r, p=$p)';
}
