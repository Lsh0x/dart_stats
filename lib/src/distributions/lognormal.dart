import 'dart:math' as math;

import '../descriptive/average.dart';
import '../descriptive/std_dev.dart';
import '../errors.dart';
import '../utils/constants.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Log-Normal distribution.
///
/// If X ~ LogNormal(mu, sigma), then ln(X) ~ Normal(mu, sigma).
class LogNormal extends Distribution {
  /// Creates a LogNormal distribution with parameters [mu] and [sigma].
  ///
  /// [mu] is the mean of the underlying normal distribution (can be any
  /// real number). [sigma] must be positive.
  LogNormal({required this.mu, required this.sigma}) {
    if (sigma <= 0) {
      throw InvalidInputException(
        'LogNormal: sigma must be positive, got sigma=$sigma',
      );
    }
  }

  /// Fits a LogNormal distribution to [data] using MLE.
  ///
  /// Takes ln(data) and computes mean and stdDev of the logs.
  /// Requires all values > 0 and at least 2 data points.
  factory LogNormal.fit(List<num> data) {
    if (data.length < 2) {
      throw const EmptyDataException(
        'LogNormal.fit requires at least 2 data points',
      );
    }
    final logs = <double>[];
    for (final x in data) {
      if (x.toDouble() <= 0) {
        throw InvalidInputException(
          'LogNormal.fit requires all values > 0, got $x',
        );
      }
      logs.add(math.log(x.toDouble()));
    }
    return LogNormal(mu: mean(logs), sigma: sampleStdDev(logs));
  }

  /// Mean of the underlying normal distribution.
  final double mu;

  /// Standard deviation of the underlying normal distribution.
  final double sigma;

  @override
  String get name => 'LogNormal';

  @override
  int get numParams => 2;

  @override
  double get distMean => math.exp(mu + sigma * sigma / 2.0);

  @override
  double get distVariance =>
      (math.exp(sigma * sigma) - 1) * math.exp(2 * mu + sigma * sigma);

  @override
  double pdf(double x) {
    if (x <= 0) return 0.0;
    final lnX = math.log(x);
    final z = (lnX - mu) / sigma;
    return invSqrt2Pi / (x * sigma) * math.exp(-0.5 * z * z);
  }

  @override
  double logpdf(double x) {
    if (x <= 0) return double.negativeInfinity;
    final lnX = math.log(x);
    final z = (lnX - mu) / sigma;
    return -0.5 * ln2Pi - math.log(sigma) - math.log(x) - 0.5 * z * z;
  }

  @override
  double cdf(double x) {
    if (x <= 0) return 0.0;
    final z = (math.log(x) - mu) / (sigma * sqrt2);
    return 0.5 * (1.0 + erf(z));
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    return bisectInverseCdf(cdf, p, lo: 1e-15, hi: math.exp(mu + 10 * sigma));
  }

  @override
  String toString() => 'LogNormal(mu=$mu, sigma=$sigma)';
}
