import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Weibull distribution with shape [k] and scale [lambda].
///
/// PDF: f(x) = (k/lambda) * (x/lambda)^(k-1) * exp(-(x/lambda)^k)
class Weibull extends Distribution {
  /// Creates a Weibull distribution with shape [k] and scale [lambda].
  ///
  /// Both must be strictly positive.
  Weibull({required this.k, required this.lambda}) {
    if (k <= 0) {
      throw InvalidInputException('Weibull: k must be positive, got k=$k');
    }
    if (lambda <= 0) {
      throw InvalidInputException(
        'Weibull: lambda must be positive, got lambda=$lambda',
      );
    }
  }

  /// Fits a Weibull distribution to [data] using Newton-Raphson MLE.
  ///
  /// All values must be > 0.
  factory Weibull.fit(List<num> data) {
    if (data.isEmpty) {
      throw const EmptyDataException('Weibull.fit requires non-empty data');
    }
    for (final x in data) {
      if (x.toDouble() <= 0) {
        throw InvalidInputException(
          'Weibull.fit requires all values > 0, got $x',
        );
      }
    }

    final n = data.length;
    final logData = data.map((x) => math.log(x.toDouble())).toList();

    // Newton-Raphson for k
    var kEst = 1.0;
    for (var iter = 0; iter < 100; iter++) {
      var sumXk = 0.0;
      var sumXkLogX = 0.0;
      var sumLogX = 0.0;

      for (var i = 0; i < n; i++) {
        final x = data[i].toDouble();
        final xk = math.pow(x, kEst).toDouble();
        sumXk += xk;
        sumXkLogX += xk * logData[i];
        sumLogX += logData[i];
      }

      final f = 1.0 / kEst + sumLogX / n - sumXkLogX / sumXk;

      var sumXkLogX2 = 0.0;
      for (var i = 0; i < n; i++) {
        final x = data[i].toDouble();
        final xk = math.pow(x, kEst).toDouble();
        sumXkLogX2 += xk * logData[i] * logData[i];
      }

      final df =
          -1.0 / (kEst * kEst) -
          (sumXkLogX2 * sumXk - sumXkLogX * sumXkLogX) / (sumXk * sumXk);

      final step = f / df;
      kEst -= step;
      if (kEst <= 0) kEst = 0.01;
      if (step.abs() < 1e-10) break;
    }

    // lambda from MLE: lambda = (sum(x^k) / n)^(1/k)
    var sumXk = 0.0;
    for (final x in data) {
      sumXk += math.pow(x.toDouble(), kEst).toDouble();
    }
    final lambdaEst = math.pow(sumXk / n, 1.0 / kEst).toDouble();

    return Weibull(k: kEst, lambda: lambdaEst);
  }

  /// Shape parameter (k > 0).
  final double k;

  /// Scale parameter (lambda > 0).
  final double lambda;

  @override
  String get name => 'Weibull';

  @override
  int get numParams => 2;

  @override
  double get distMean => lambda * math.exp(lnGamma(1.0 + 1.0 / k));

  @override
  double get distVariance {
    final g1 = math.exp(lnGamma(1.0 + 1.0 / k));
    final g2 = math.exp(lnGamma(1.0 + 2.0 / k));
    return lambda * lambda * (g2 - g1 * g1);
  }

  @override
  double pdf(double x) {
    if (x < 0) return 0.0;
    if (x == 0) {
      if (k < 1) return double.infinity;
      if (k == 1) return 1.0 / lambda;
      return 0.0;
    }
    final xOverL = x / lambda;
    return (k / lambda) *
        math.pow(xOverL, k - 1.0) *
        math.exp(-math.pow(xOverL, k));
  }

  @override
  double logpdf(double x) {
    if (x <= 0) return double.negativeInfinity;
    final xOverL = x / lambda;
    return math.log(k / lambda) +
        (k - 1.0) * math.log(xOverL) -
        math.pow(xOverL, k);
  }

  @override
  double cdf(double x) {
    if (x <= 0) return 0.0;
    return 1.0 - math.exp(-math.pow(x / lambda, k));
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    // Closed form: x = lambda * (-ln(1-p))^(1/k)
    return lambda * math.pow(-math.log(1.0 - p), 1.0 / k).toDouble();
  }

  @override
  String toString() => 'Weibull(k=$k, lambda=$lambda)';
}
