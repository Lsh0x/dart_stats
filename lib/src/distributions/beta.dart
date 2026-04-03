import 'dart:math' as math;

import '../descriptive/average.dart';
import '../descriptive/variance.dart';
import '../errors.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Beta distribution with shape parameters [alpha] and [beta].
///
/// PDF: f(x) = x^(a-1) * (1-x)^(b-1) / B(a,b)  for x in [0, 1].
class Beta extends Distribution {
  /// Creates a Beta distribution with shape parameters [alpha] and [beta].
  ///
  /// Both must be strictly positive.
  Beta({required this.alpha, required this.beta}) {
    if (alpha <= 0) {
      throw InvalidInputException(
        'Beta: alpha must be positive, got alpha=$alpha',
      );
    }
    if (beta <= 0) {
      throw InvalidInputException(
        'Beta: beta must be positive, got beta=$beta',
      );
    }
  }

  /// Fits a Beta distribution to [data] using method of moments.
  ///
  /// All values must be in (0, 1).
  factory Beta.fit(List<num> data) {
    if (data.isEmpty) {
      throw const EmptyDataException('Beta.fit requires non-empty data');
    }
    for (final x in data) {
      final v = x.toDouble();
      if (v <= 0 || v >= 1) {
        throw InvalidInputException(
          'Beta.fit requires all values in (0, 1), got $x',
        );
      }
    }

    final m = mean(data);
    final v = sampleVariance(data);

    // Method of moments:
    // alpha = mean * ((mean * (1-mean) / variance) - 1)
    // beta  = (1 - mean) * ((mean * (1-mean) / variance) - 1)
    final common = m * (1.0 - m) / v - 1.0;
    if (common <= 0) {
      // Fallback: variance too large for method of moments
      return Beta(alpha: 1.0, beta: 1.0);
    }

    return Beta(alpha: m * common, beta: (1.0 - m) * common);
  }

  /// Shape parameter alpha > 0.
  final double alpha;

  /// Shape parameter beta > 0.
  final double beta;

  @override
  String get name => 'Beta';

  @override
  int get numParams => 2;

  @override
  double get distMean => alpha / (alpha + beta);

  @override
  double get distVariance =>
      (alpha * beta) / ((alpha + beta) * (alpha + beta) * (alpha + beta + 1.0));

  @override
  double pdf(double x) {
    if (x <= 0 || x >= 1) return 0.0;
    return math.exp(logpdf(x));
  }

  @override
  double logpdf(double x) {
    if (x <= 0 || x >= 1) return double.negativeInfinity;
    return (alpha - 1.0) * math.log(x) +
        (beta - 1.0) * math.log(1.0 - x) -
        lnBeta(alpha, beta);
  }

  @override
  double cdf(double x) {
    if (x <= 0) return 0.0;
    if (x >= 1) return 1.0;
    return regularizedIncompleteBeta(alpha, beta, x);
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    return bisectInverseCdf(cdf, p, lo: 0.0, hi: 1.0);
  }

  @override
  String toString() => 'Beta(alpha=$alpha, beta=$beta)';
}
