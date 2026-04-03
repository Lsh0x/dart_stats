import 'dart:math' as math;

import '../descriptive/average.dart';
import '../errors.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Gamma distribution with shape parameter [alpha] and rate parameter [beta].
///
/// PDF: f(x) = beta^alpha * x^(alpha-1) * exp(-beta*x) / Gamma(alpha)
///
/// Parameterization: shape/rate (scale = 1/beta).
class GammaDistribution extends Distribution {
  /// Creates a Gamma distribution with shape [alpha] and rate [beta].
  ///
  /// Both parameters must be strictly positive.
  /// Throws [InvalidInputException] if either is <= 0.
  GammaDistribution({required this.alpha, required this.beta}) {
    if (alpha <= 0) {
      throw InvalidInputException(
        'GammaDistribution: alpha must be positive, got alpha=$alpha',
      );
    }
    if (beta <= 0) {
      throw InvalidInputException(
        'GammaDistribution: beta must be positive, got beta=$beta',
      );
    }
  }

  /// Fits a Gamma distribution to [data] using MLE (Choi-Wette approximation).
  ///
  /// All values must be > 0.
  /// Algorithm:
  /// 1. s = ln(mean) - mean(ln(x))
  /// 2. alpha = (3 - s + sqrt((s-3)^2 + 24s)) / (12s)
  /// 3. beta = alpha / mean
  factory GammaDistribution.fit(List<num> data) {
    if (data.isEmpty) {
      throw const EmptyDataException(
        'GammaDistribution.fit requires non-empty data',
      );
    }
    for (final x in data) {
      if (x.toDouble() <= 0) {
        throw InvalidInputException(
          'GammaDistribution.fit requires all values > 0, got $x',
        );
      }
    }

    final m = mean(data);
    var logMean = 0.0;
    for (final x in data) {
      logMean += math.log(x.toDouble());
    }
    logMean /= data.length;

    final s = math.log(m) - logMean;

    final double a;
    if (s <= 0 || s.isNaN) {
      a = 1.0;
    } else {
      a = (3.0 - s + math.sqrt((s - 3.0) * (s - 3.0) + 24.0 * s)) / (12.0 * s);
    }

    return GammaDistribution(alpha: a, beta: a / m);
  }

  /// Shape parameter (alpha > 0).
  final double alpha;

  /// Rate parameter (beta > 0). Scale = 1/beta.
  final double beta;

  @override
  String get name => 'Gamma';

  @override
  int get numParams => 2;

  @override
  double get distMean => alpha / beta;

  @override
  double get distVariance => alpha / (beta * beta);

  @override
  double pdf(double x) {
    if (x <= 0) return 0.0;
    return math.exp(logpdf(x));
  }

  @override
  double logpdf(double x) {
    if (x <= 0) return double.negativeInfinity;
    return alpha * math.log(beta) +
        (alpha - 1.0) * math.log(x) -
        beta * x -
        lnGamma(alpha);
  }

  @override
  double cdf(double x) {
    if (x <= 0) return 0.0;
    return regularizedIncompleteGamma(alpha, beta * x);
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    final hi = distMean + 10.0 * distStdDev;
    return bisectInverseCdf(cdf, p, lo: 0.0, hi: hi < 1.0 ? 1.0 : hi);
  }

  @override
  String toString() => 'Gamma(alpha=$alpha, beta=$beta)';
}
