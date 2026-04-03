import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'discrete_distribution.dart';

/// Binomial distribution with [n] trials and success probability [p].
///
/// PMF: P(k) = C(n,k) * p^k * (1-p)^(n-k)
class Binomial extends DiscreteDistribution {
  /// Creates a Binomial distribution with [n] trials and probability [p].
  ///
  /// Throws [InvalidInputException] if n < 0 or p not in [0, 1].
  Binomial({required this.n, required this.p}) {
    if (n < 0) {
      throw InvalidInputException('Binomial: n must be non-negative, got n=$n');
    }
    if (p < 0 || p > 1) {
      throw InvalidInputException('Binomial: p must be in [0,1], got p=$p');
    }
  }

  /// Fits a Binomial distribution to [data] using MLE.
  ///
  /// Requires [n] (number of trials) to be specified.
  /// MLE for p = mean(data) / n.
  factory Binomial.fit(List<int> data, {required int n}) {
    if (data.isEmpty) {
      throw const EmptyDataException('Binomial.fit requires non-empty data');
    }
    if (n <= 0) {
      throw InvalidInputException('Binomial.fit: n must be positive, got n=$n');
    }
    final sum = data.fold(0, (a, b) => a + b);
    final pEst = sum / (data.length * n);
    return Binomial(n: n, p: pEst.clamp(0.0, 1.0));
  }

  /// Number of trials.
  final int n;

  /// Success probability.
  final double p;

  @override
  String get name => 'Binomial';

  @override
  int get numParams => 1; // p (n is fixed)

  @override
  double get distMean => n * p;

  @override
  double get distVariance => n * p * (1.0 - p);

  @override
  double pmf(int k) {
    if (k < 0 || k > n) return 0.0;
    return math.exp(logpmf(k));
  }

  @override
  double logpmf(int k) {
    if (k < 0 || k > n) return double.negativeInfinity;
    // Use lnGamma for numerical stability: ln(C(n,k)) = lnGamma(n+1) - lnGamma(k+1) - lnGamma(n-k+1)
    return lnGamma(n + 1.0) -
        lnGamma(k + 1.0) -
        lnGamma(n - k + 1.0) +
        k * math.log(p) +
        (n - k) * math.log(1.0 - p);
  }

  @override
  double cdf(int k) {
    if (k < 0) return 0.0;
    if (k >= n) return 1.0;
    var sum = 0.0;
    for (var i = 0; i <= k; i++) {
      sum += pmf(i);
    }
    return sum;
  }

  @override
  int inverseCdf(double p) {
    if (p <= 0) return 0;
    if (p >= 1) return n;
    var cumulative = 0.0;
    for (var k = 0; k <= n; k++) {
      cumulative += pmf(k);
      if (cumulative >= p) return k;
    }
    return n;
  }

  @override
  String toString() => 'Binomial(n=$n, p=$p)';
}
