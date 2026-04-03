import 'dart:math' as math;

import '../descriptive/average.dart';
import '../descriptive/std_dev.dart';
import '../errors.dart';
import '../utils/constants.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Normal (Gaussian) distribution.
class Normal extends Distribution {
  /// Creates a Normal distribution with mean [mu] and standard
  /// deviation [sigma].
  ///
  /// Throws [InvalidInputException] if [sigma] ≤ 0.
  Normal({required this.mu, required this.sigma}) {
    if (sigma <= 0) {
      throw InvalidInputException(
        'Normal: sigma must be positive, got sigma=$sigma',
      );
    }
  }

  /// Fits a Normal distribution to [data] using MLE.
  ///
  /// MLE for Normal: mu = mean(data), sigma = stdDev(data).
  /// Requires at least 2 elements.
  factory Normal.fit(List<num> data) {
    if (data.length < 2) {
      throw const EmptyDataException(
        'Normal.fit requires at least 2 data points',
      );
    }
    return Normal(mu: mean(data), sigma: sampleStdDev(data));
  }

  /// Mean parameter.
  final double mu;

  /// Standard deviation parameter.
  final double sigma;

  @override
  String get name => 'Normal';

  @override
  int get numParams => 2;

  @override
  double get distMean => mu;

  @override
  double get distVariance => sigma * sigma;

  @override
  double get distStdDev => sigma;

  @override
  double pdf(double x) {
    final z = (x - mu) / sigma;
    return invSqrt2Pi / sigma * math.exp(-0.5 * z * z);
  }

  @override
  double logpdf(double x) {
    final z = (x - mu) / sigma;
    return -0.5 * ln2Pi - math.log(sigma) - 0.5 * z * z;
  }

  @override
  double cdf(double x) {
    final z = (x - mu) / (sigma * sqrt2);
    return 0.5 * (1.0 + erf(z));
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    return bisectInverseCdf(cdf, p, lo: mu - 10 * sigma, hi: mu + 10 * sigma);
  }

  @override
  String toString() => 'Normal(mu=$mu, sigma=$sigma)';
}
