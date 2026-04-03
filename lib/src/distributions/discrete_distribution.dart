import 'dart:math' as math;

/// Abstract base class for discrete probability distributions.
///
/// Discrete distributions use PMF (probability mass function) instead of PDF.
abstract class DiscreteDistribution {
  /// Distribution name (e.g., "Binomial", "Poisson").
  String get name;

  /// Number of parameters.
  int get numParams;

  /// Probability mass function at [k].
  double pmf(int k);

  /// Log of the probability mass function at [k].
  double logpmf(int k) {
    final p = pmf(k);
    return p > 0 ? math.log(p) : double.negativeInfinity;
  }

  /// Cumulative distribution function: P(X <= [k]).
  double cdf(int k);

  /// Inverse CDF (quantile function).
  /// Returns smallest k such that CDF(k) >= [p].
  int inverseCdf(double p);

  /// Distribution mean.
  double get distMean;

  /// Distribution variance.
  double get distVariance;

  /// Distribution standard deviation.
  double get distStdDev => math.sqrt(distVariance);

  /// Log-likelihood of [data] under this distribution.
  double logLikelihood(List<int> data) {
    var ll = 0.0;
    for (final k in data) {
      ll += logpmf(k);
    }
    return ll;
  }

  /// Akaike Information Criterion.
  double aic(List<int> data) => -2.0 * logLikelihood(data) + 2.0 * numParams;

  /// Bayesian Information Criterion.
  double bic(List<int> data) =>
      -2.0 * logLikelihood(data) + numParams * math.log(data.length);
}
