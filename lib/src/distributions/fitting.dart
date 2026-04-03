import 'dart:math' as math;

import '../errors.dart';
import 'distribution.dart';
import 'exponential.dart';
import 'lognormal.dart';
import 'normal.dart';
import 'uniform.dart';

/// Result of fitting a distribution to data.
class FitResult implements Comparable<FitResult> {
  /// Creates a [FitResult].
  const FitResult({
    required this.name,
    required this.aic,
    required this.bic,
    required this.distribution,
  });

  /// Distribution name.
  final String name;

  /// Akaike Information Criterion (lower is better).
  final double aic;

  /// Bayesian Information Criterion (lower is better).
  final double bic;

  /// The fitted distribution instance.
  final Distribution distribution;

  @override
  int compareTo(FitResult other) => aic.compareTo(other.aic);

  @override
  String toString() => 'FitResult($name, AIC=${aic.toStringAsFixed(2)})';
}

/// Result of a Kolmogorov-Smirnov test.
class KsResult {
  /// Creates a [KsResult].
  const KsResult({required this.statistic, required this.pValue});

  /// KS statistic (maximum absolute deviation between empirical and
  /// theoretical CDF).
  final double statistic;

  /// Approximate p-value.
  final double pValue;

  @override
  String toString() =>
      'KsResult(D=${statistic.toStringAsFixed(4)}, '
      'p=${pValue.toStringAsFixed(4)})';
}

/// Fits all continuous distributions and returns results sorted by AIC.
///
/// Tries Normal, LogNormal, Exponential, and Uniform.
/// Skips distributions that fail to fit (e.g., LogNormal with negative
/// data).
List<FitResult> fitAll(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('fitAll requires non-empty data');
  }

  final results = <FitResult>[];

  // Try each distribution, skip on failure
  for (final fitter in _fitters) {
    try {
      final dist = fitter(data);
      final aic = dist.aic(data);
      final bic = dist.bic(data);
      if (!aic.isNaN && !aic.isInfinite) {
        results.add(
          FitResult(name: dist.name, aic: aic, bic: bic, distribution: dist),
        );
      }
    } on StatsException {
      // Skip distributions that can't fit this data
    }
  }

  results.sort();
  return results;
}

/// Returns the single best-fitting distribution (lowest AIC).
FitResult fitBest(List<num> data) {
  final results = fitAll(data);
  if (results.isEmpty) {
    throw const EmptyDataException(
      'No distribution could be fitted to the data',
    );
  }
  return results.first;
}

/// Auto-detect the best distribution for [data].
///
/// Same as [fitBest] — fits all candidates and returns the best one.
FitResult autoFit(List<num> data) => fitBest(data);

/// Two-sided Kolmogorov-Smirnov goodness-of-fit test.
///
/// Tests whether [data] was drawn from a distribution with the given
/// [cdf]. Returns the KS statistic and approximate p-value.
KsResult ksTest(List<num> data, double Function(double) cdf) {
  if (data.isEmpty) {
    throw const EmptyDataException('ksTest requires non-empty data');
  }

  final sorted = [...data]..sort();
  final n = sorted.length;

  var maxD = 0.0;

  for (var i = 0; i < n; i++) {
    final x = sorted[i].toDouble();
    final empiricalBefore = i / n;
    final empiricalAfter = (i + 1) / n;
    final theoretical = cdf(x);

    final d1 = (empiricalAfter - theoretical).abs();
    final d2 = (empiricalBefore - theoretical).abs();

    maxD = math.max(maxD, math.max(d1, d2));
  }

  // Approximate p-value using Kolmogorov distribution
  final p = _ksApproxPValue(maxD, n);

  return KsResult(statistic: maxD, pValue: p);
}

/// Approximate p-value for KS test using the asymptotic formula.
double _ksApproxPValue(double d, int n) {
  final sqrtN = math.sqrt(n.toDouble());
  final z = (sqrtN + 0.12 + 0.11 / sqrtN) * d;

  if (z < 0.27) return 1.0;
  if (z > 3.1) return 0.0;

  // Marsaglia et al. two-term approximation
  var sum = 0.0;
  for (var k = 1; k <= 100; k++) {
    final sign = k.isOdd ? 1.0 : -1.0;
    sum += sign * math.exp(-2.0 * k * k * z * z);
  }
  return (2.0 * sum).clamp(0.0, 1.0);
}

/// Distribution fitters — each takes data and returns a fitted Distribution.
final List<Distribution Function(List<num>)> _fitters = [
  Normal.fit,
  LogNormal.fit,
  Exponential.fit,
  Uniform.fit,
];
