import '../descriptive/average.dart';
import '../distributions/f_distribution.dart';
import '../errors.dart';

/// Result of a one-way ANOVA test.
class AnovaResult {
  /// Creates an [AnovaResult].
  const AnovaResult({
    required this.fStatistic,
    required this.pValue,
    required this.dfBetween,
    required this.dfWithin,
    required this.ssBetween,
    required this.ssWithin,
    required this.msBetween,
    required this.msWithin,
  });

  /// F-statistic (ratio of between-group to within-group variance).
  final double fStatistic;

  /// Two-tailed p-value.
  final double pValue;

  /// Degrees of freedom between groups.
  final int dfBetween;

  /// Degrees of freedom within groups.
  final int dfWithin;

  /// Sum of squares between groups.
  final double ssBetween;

  /// Sum of squares within groups.
  final double ssWithin;

  /// Mean square between groups.
  final double msBetween;

  /// Mean square within groups.
  final double msWithin;

  @override
  String toString() =>
      'AnovaResult(F=$fStatistic, p=$pValue, dfB=$dfBetween, dfW=$dfWithin)';
}

/// One-way Analysis of Variance (ANOVA).
///
/// Tests whether the means of [groups] are all equal.
/// Requires at least 2 groups, each with at least 2 observations.
///
/// Returns an [AnovaResult] with F-statistic, p-value, and full ANOVA table.
AnovaResult oneWayAnova(List<List<num>> groups) {
  if (groups.length < 2) {
    throw const InvalidInputException('ANOVA requires at least 2 groups');
  }

  for (var i = 0; i < groups.length; i++) {
    if (groups[i].length < 2) {
      throw InvalidInputException(
        'ANOVA: each group must have at least 2 observations '
        '(group $i has ${groups[i].length})',
      );
    }
  }

  // Convert to doubles
  final data = groups.map((g) => g.map((v) => v.toDouble()).toList()).toList();

  // Grand mean
  final nTotal = data.fold(0, (sum, g) => sum + g.length);
  final grandSum = data.fold(0.0, (s, g) => s + g.fold(0.0, (a, b) => a + b));
  final grandMean = grandSum / nTotal;

  // Group means
  final groupMeans = data.map(mean).toList();

  // Sum of squares between groups
  var ssBetween = 0.0;
  for (var i = 0; i < data.length; i++) {
    final diff = groupMeans[i] - grandMean;
    ssBetween += diff * diff * data[i].length;
  }

  // Sum of squares within groups
  var ssWithin = 0.0;
  for (var i = 0; i < data.length; i++) {
    for (final x in data[i]) {
      final diff = x - groupMeans[i];
      ssWithin += diff * diff;
    }
  }

  // Degrees of freedom
  final dfBetween = groups.length - 1;
  final dfWithin = nTotal - groups.length;

  // Mean squares
  final msBetween = ssBetween / dfBetween;
  final msWithin = ssWithin / dfWithin;

  // F-statistic
  final f = msBetween / msWithin;

  // p-value via F distribution CDF
  double pValue;
  if (f.isNaN || f.isInfinite) {
    pValue = f.isNaN ? 1.0 : 0.0;
  } else {
    final fDist = FDistribution(
      df1: dfBetween.toDouble(),
      df2: dfWithin.toDouble(),
    );
    pValue = 1.0 - fDist.cdf(f);
  }

  return AnovaResult(
    fStatistic: f,
    pValue: pValue,
    dfBetween: dfBetween,
    dfWithin: dfWithin,
    ssBetween: ssBetween,
    ssWithin: ssWithin,
    msBetween: msBetween,
    msWithin: msWithin,
  );
}
