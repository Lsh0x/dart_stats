import 'dart:math' as math;

import '../errors.dart';
import 'average.dart';
import 'percentile.dart';

/// Population skewness (third standardized moment) of [data].
///
/// Measures the asymmetry of the distribution.
/// Positive = right tail longer, negative = left tail longer.
///
/// Uses the formula: (1/n) × Σ((xi − μ)/σ)³
/// Throws [EmptyDataException] if [data] has fewer than 3 elements.
double skewness(List<num> data) {
  if (data.length < 3) {
    throw const EmptyDataException(
      'Skewness requires at least 3 elements',
    );
  }
  final mu = mean(data);
  final sigma = _popStdDev(data, mu);
  if (sigma == 0) return 0.0;

  var sum = 0.0;
  for (final x in data) {
    final z = (x - mu) / sigma;
    sum += z * z * z;
  }
  return sum / data.length;
}

/// Sample skewness (adjusted for bias) of [data].
///
/// Uses the formula: [n/((n-1)(n-2))] × Σ((xi − x̄)/s)³
/// Throws [EmptyDataException] if [data] has fewer than 3 elements.
double sampleSkewness(List<num> data) {
  if (data.length < 3) {
    throw const EmptyDataException(
      'Sample skewness requires at least 3 elements',
    );
  }
  final n = data.length;
  final mu = mean(data);
  final s = _sampleStdDev(data, mu);
  if (s == 0) return 0.0;

  var sum = 0.0;
  for (final x in data) {
    final z = (x - mu) / s;
    sum += z * z * z;
  }
  return (n / ((n - 1) * (n - 2))) * sum;
}

/// Excess kurtosis (fourth standardized moment minus 3) of [data].
///
/// Normal distribution has excess kurtosis = 0.
/// Positive = heavier tails (leptokurtic), negative = lighter tails (platykurtic).
///
/// Uses the population formula: [(1/n) × Σ((xi − μ)/σ)⁴] − 3
/// Throws [EmptyDataException] if [data] has fewer than 4 elements.
double kurtosis(List<num> data) {
  if (data.length < 4) {
    throw const EmptyDataException(
      'Kurtosis requires at least 4 elements',
    );
  }
  final mu = mean(data);
  final sigma = _popStdDev(data, mu);
  if (sigma == 0) return -3.0; // degenerate: all values equal

  var sum = 0.0;
  for (final x in data) {
    final z = (x - mu) / sigma;
    final z2 = z * z;
    sum += z2 * z2;
  }
  return sum / data.length - 3.0;
}

/// Sample excess kurtosis (bias-corrected) of [data].
///
/// Uses Fisher's definition with bias correction (same as scipy.stats):
/// (n(n+1)/((n-1)(n-2)(n-3))) × Σ((xi − x̄)/s)⁴ − 3(n-1)²/((n-2)(n-3))
/// Throws [EmptyDataException] if [data] has fewer than 4 elements.
double sampleKurtosis(List<num> data) {
  if (data.length < 4) {
    throw const EmptyDataException(
      'Sample kurtosis requires at least 4 elements',
    );
  }
  final n = data.length;
  final mu = mean(data);
  final s = _sampleStdDev(data, mu);
  if (s == 0) return -3.0 * (n - 1) * (n - 1) / ((n - 2) * (n - 3));

  var sum = 0.0;
  for (final x in data) {
    final z = (x - mu) / s;
    final z2 = z * z;
    sum += z2 * z2;
  }
  final term1 = (n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3)) * sum;
  final term2 = 3.0 * (n - 1) * (n - 1) / ((n - 2) * (n - 3));
  return term1 - term2;
}

/// Median Absolute Deviation (MAD) of [data].
///
/// MAD = median(|xi − median(x)|)
///
/// A robust measure of variability. Multiply by 1.4826 to estimate σ
/// for normally distributed data.
///
/// Throws [EmptyDataException] if [data] is empty.
double mad(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute MAD of empty list');
  }
  final med = median(data);
  final deviations = data.map((x) => (x - med).abs()).toList();
  return median(deviations);
}

/// Trimmed mean: arithmetic mean after removing the lowest and highest
/// [proportion] fraction of data.
///
/// [proportion] is the fraction to trim from **each** end (0.0 to < 0.5).
/// For example, `trimmedMean(data, 0.1)` removes the bottom 10% and top 10%.
///
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if [proportion] is not in [0, 0.5).
double trimmedMean(List<num> data, double proportion) {
  if (data.isEmpty) {
    throw const EmptyDataException(
      'Cannot compute trimmed mean of empty list',
    );
  }
  if (proportion < 0 || proportion >= 0.5) {
    throw InvalidInputException(
      'Proportion must be in [0, 0.5), got $proportion',
    );
  }

  final sorted = [...data]..sort();
  final n = sorted.length;
  final trimCount = (n * proportion).floor();

  if (trimCount == 0) return mean(sorted);

  final trimmed = sorted.sublist(trimCount, n - trimCount);
  if (trimmed.isEmpty) return mean(sorted);
  return mean(trimmed);
}

/// Winsorized mean: replace the lowest and highest [proportion] fraction
/// of data with the nearest unclipped value, then take the mean.
///
/// [proportion] is the fraction to winsorize from **each** end (0.0 to < 0.5).
/// Unlike [trimmedMean], values are not removed but clamped to the
/// boundary values.
///
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if [proportion] is not in [0, 0.5).
double winsorizedMean(List<num> data, double proportion) {
  if (data.isEmpty) {
    throw const EmptyDataException(
      'Cannot compute winsorized mean of empty list',
    );
  }
  if (proportion < 0 || proportion >= 0.5) {
    throw InvalidInputException(
      'Proportion must be in [0, 0.5), got $proportion',
    );
  }

  final sorted = [...data]..sort();
  final n = sorted.length;
  final trimCount = (n * proportion).floor();

  if (trimCount == 0) return mean(sorted);

  final lo = sorted[trimCount].toDouble();
  final hi = sorted[n - trimCount - 1].toDouble();

  var sum = 0.0;
  for (final x in sorted) {
    final v = x.toDouble();
    if (v < lo) {
      sum += lo;
    } else if (v > hi) {
      sum += hi;
    } else {
      sum += v;
    }
  }
  return sum / n;
}

// ── internal helpers ──

double _popStdDev(List<num> data, double mu) {
  var sum = 0.0;
  for (final x in data) {
    final d = x - mu;
    sum += d * d;
  }
  return math.sqrt(sum / data.length);
}

double _sampleStdDev(List<num> data, double mu) {
  if (data.length < 2) return 0.0;
  var sum = 0.0;
  for (final x in data) {
    final d = x - mu;
    sum += d * d;
  }
  return math.sqrt(sum / (data.length - 1));
}
