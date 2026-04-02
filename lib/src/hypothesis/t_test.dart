import 'dart:math' as math;

import '../descriptive/average.dart';
import '../descriptive/std_dev.dart';
import '../descriptive/std_err.dart';
import '../errors.dart';
import '../utils/special_functions.dart';

/// Result of a t-test.
class TTestResult {
  /// Creates a [TTestResult].
  const TTestResult({
    required this.tStatistic,
    required this.pValue,
    required this.degreesOfFreedom,
    required this.meanDiff,
    required this.stdError,
  });

  /// The t-statistic.
  final double tStatistic;

  /// Two-tailed p-value.
  final double pValue;

  /// Degrees of freedom.
  final int degreesOfFreedom;

  /// Difference of means (or mean of differences for paired).
  final double meanDiff;

  /// Standard error of the difference.
  final double stdError;

  @override
  String toString() =>
      'TTestResult(t=$tStatistic, p=$pValue, df=$degreesOfFreedom)';
}

/// One-sample t-test: tests whether the mean of [data] differs from [mu].
///
/// Returns a [TTestResult] with two-tailed p-value.
/// Requires at least 2 elements.
TTestResult oneSampleTTest(List<num> data, double mu) {
  if (data.length < 2) {
    throw const EmptyDataException(
      'One-sample t-test requires at least 2 elements',
    );
  }

  final m = mean(data);
  final se = stdErr(data);
  final df = data.length - 1;

  // Handle zero variance (all identical values)
  if (se == 0) {
    final diff = m - mu;
    return TTestResult(
      tStatistic: diff == 0 ? 0.0 : double.infinity * diff.sign,
      pValue: diff == 0 ? 1.0 : 0.0,
      degreesOfFreedom: df,
      meanDiff: diff,
      stdError: 0.0,
    );
  }

  final t = (m - mu) / se;
  final p = _twoTailedPValue(t, df);

  return TTestResult(
    tStatistic: t,
    pValue: p,
    degreesOfFreedom: df,
    meanDiff: m - mu,
    stdError: se,
  );
}

/// Paired t-test: tests whether mean difference between
/// [before] and [after] is zero.
///
/// Computes differences (before - after) then runs a one-sample t-test
/// against mu=0. Requires same length, at least 2 pairs.
TTestResult pairedTTest(List<num> before, List<num> after) {
  if (before.isEmpty || after.isEmpty) {
    throw const EmptyDataException(
      'Paired t-test requires non-empty data',
    );
  }
  if (before.length != after.length) {
    throw DimensionMismatchException(
      'Paired t-test requires same length, '
      'got ${before.length} and ${after.length}',
    );
  }
  if (before.length < 2) {
    throw const EmptyDataException(
      'Paired t-test requires at least 2 pairs',
    );
  }

  final diffs = <double>[
    for (var i = 0; i < before.length; i++)
      before[i].toDouble() - after[i].toDouble(),
  ];

  // Handle constant differences (stddev = 0)
  final sd = sampleStdDev(diffs);
  if (sd == 0) {
    final m = mean(diffs);
    return TTestResult(
      tStatistic: m == 0 ? 0.0 : double.infinity * m.sign,
      pValue: m == 0 ? 1.0 : 0.0,
      degreesOfFreedom: diffs.length - 1,
      meanDiff: m,
      stdError: 0.0,
    );
  }

  return oneSampleTTest(diffs, 0.0);
}

/// Two-sample (Welch's) t-test: tests whether two independent
/// samples have the same mean.
///
/// Uses Welch's approximation for unequal variances.
TTestResult twoSampleTTest(List<num> a, List<num> b) {
  if (a.length < 2) {
    throw const EmptyDataException(
      'Two-sample t-test requires at least 2 elements in each sample',
    );
  }
  if (b.length < 2) {
    throw const EmptyDataException(
      'Two-sample t-test requires at least 2 elements in each sample',
    );
  }

  final m1 = mean(a);
  final m2 = mean(b);
  final v1 = sampleStdDev(a) * sampleStdDev(a);
  final v2 = sampleStdDev(b) * sampleStdDev(b);
  final n1 = a.length.toDouble();
  final n2 = b.length.toDouble();

  final se = math.sqrt(v1 / n1 + v2 / n2);
  final t = (m1 - m2) / se;

  // Welch-Satterthwaite degrees of freedom
  final num1 = (v1 / n1 + v2 / n2) * (v1 / n1 + v2 / n2);
  final den1 = (v1 / n1) * (v1 / n1) / (n1 - 1);
  final den2 = (v2 / n2) * (v2 / n2) / (n2 - 1);
  final df = (num1 / (den1 + den2)).floor();

  final p = _twoTailedPValue(t, df);

  return TTestResult(
    tStatistic: t,
    pValue: p,
    degreesOfFreedom: df,
    meanDiff: m1 - m2,
    stdError: se,
  );
}

/// Two-tailed p-value from Student's t-distribution.
///
/// Uses the regularized incomplete beta function:
/// p = I_{v/(v+t²)}(v/2, 1/2)
double _twoTailedPValue(double t, int df) {
  if (t == 0) return 1.0;
  if (t.isInfinite) return 0.0;

  final x = df / (df + t * t);
  return regularizedIncompleteBeta(df / 2.0, 0.5, x);
}
