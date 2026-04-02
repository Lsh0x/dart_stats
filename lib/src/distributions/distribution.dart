import 'dart:math' as math;

/// Abstract base class for continuous probability distributions.
abstract class Distribution {
  /// Distribution name (e.g., "Normal", "LogNormal").
  String get name;

  /// Number of parameters.
  int get numParams;

  /// Probability density function at [x].
  double pdf(double x);

  /// Log of the probability density function at [x].
  double logpdf(double x) => math.log(pdf(x));

  /// Cumulative distribution function at [x].
  double cdf(double x);

  /// Inverse CDF (quantile function). Returns x such that CDF(x) = [p].
  double inverseCdf(double p);

  /// Distribution mean.
  double get distMean;

  /// Distribution variance.
  double get distVariance;

  /// Distribution standard deviation.
  double get distStdDev => math.sqrt(distVariance);

  /// Log-likelihood of [data] under this distribution.
  double logLikelihood(List<num> data) {
    var ll = 0.0;
    for (final x in data) {
      ll += logpdf(x.toDouble());
    }
    return ll;
  }

  /// Akaike Information Criterion.
  /// AIC = -2 * logLikelihood + 2 * numParams
  double aic(List<num> data) => -2.0 * logLikelihood(data) + 2.0 * numParams;

  /// Bayesian Information Criterion.
  /// BIC = -2 * logLikelihood + numParams * ln(n)
  double bic(List<num> data) =>
      -2.0 * logLikelihood(data) + numParams * math.log(data.length);
}
