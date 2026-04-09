import 'dart:math' as math;

import '../descriptive/average.dart';
import '../descriptive/percentile.dart';
import '../errors.dart';

/// Result of a bootstrap resampling procedure.
class BootstrapResult {
  /// Point estimate of the statistic (mean of bootstrap replicates).
  final double estimate;

  /// Lower bound of the confidence interval.
  final double ciLower;

  /// Upper bound of the confidence interval.
  final double ciUpper;

  /// Confidence level used (e.g. 0.95).
  final double confidenceLevel;

  /// Standard error of the bootstrap distribution.
  final double standardError;

  /// Number of resamples performed.
  final int nResamples;

  /// All bootstrap replicate values (sorted).
  final List<double> replicates;

  const BootstrapResult({
    required this.estimate,
    required this.ciLower,
    required this.ciUpper,
    required this.confidenceLevel,
    required this.standardError,
    required this.nResamples,
    required this.replicates,
  });
}

/// Performs bootstrap resampling on [data] using [statistic].
///
/// [statistic] is a function that computes the desired measure from a sample
/// (e.g., [mean], [median], or any custom function).
///
/// [nResamples] defaults to 1000. Higher values give more precise CIs.
/// [confidenceLevel] defaults to 0.95 (95% CI).
/// [seed] makes results reproducible when set.
///
/// Returns a [BootstrapResult] with the point estimate, percentile CI,
/// and all bootstrap replicates.
///
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if [confidenceLevel] is not in (0, 1).
BootstrapResult bootstrap(
  List<num> data,
  double Function(List<num>) statistic, {
  int nResamples = 1000,
  double confidenceLevel = 0.95,
  int? seed,
}) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot bootstrap empty data');
  }
  if (confidenceLevel <= 0 || confidenceLevel >= 1) {
    throw InvalidInputException(
      'Confidence level must be in (0, 1), got $confidenceLevel',
    );
  }

  final rng = seed != null ? math.Random(seed) : math.Random();
  final n = data.length;
  final replicates = <double>[];

  for (var r = 0; r < nResamples; r++) {
    // Resample with replacement
    final sample = List<num>.generate(n, (_) => data[rng.nextInt(n)]);
    replicates.add(statistic(sample));
  }

  replicates.sort();

  final estimate = mean(replicates);

  // Percentile CI
  final alpha = 1 - confidenceLevel;
  final ciLower = percentile(replicates, alpha / 2);
  final ciUpper = percentile(replicates, 1 - alpha / 2);

  // Standard error = std dev of replicates
  var sumSq = 0.0;
  for (final v in replicates) {
    final d = v - estimate;
    sumSq += d * d;
  }
  final se = math.sqrt(sumSq / (replicates.length - 1));

  return BootstrapResult(
    estimate: estimate,
    ciLower: ciLower,
    ciUpper: ciUpper,
    confidenceLevel: confidenceLevel,
    standardError: se,
    nResamples: nResamples,
    replicates: replicates,
  );
}
