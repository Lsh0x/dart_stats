import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// F-distribution (Fisher-Snedecor) with [df1] and [df2] degrees of freedom.
///
/// Used for ANOVA F-tests.
class FDistribution extends Distribution {
  /// Creates an F-distribution with [df1] and [df2] degrees of freedom.
  ///
  /// Both must be strictly positive.
  FDistribution({required this.df1, required this.df2}) {
    if (df1 <= 0) {
      throw InvalidInputException(
        'FDistribution: df1 must be positive, got df1=$df1',
      );
    }
    if (df2 <= 0) {
      throw InvalidInputException(
        'FDistribution: df2 must be positive, got df2=$df2',
      );
    }
  }

  /// Numerator degrees of freedom.
  final double df1;

  /// Denominator degrees of freedom.
  final double df2;

  @override
  String get name => 'F';

  @override
  int get numParams => 2;

  @override
  double get distMean => df2 > 2 ? df2 / (df2 - 2.0) : double.nan;

  @override
  double get distVariance {
    if (df2 <= 4) return double.nan;
    return 2.0 *
        df2 *
        df2 *
        (df1 + df2 - 2.0) /
        (df1 * (df2 - 2.0) * (df2 - 2.0) * (df2 - 4.0));
  }

  @override
  double pdf(double x) {
    if (x <= 0) return 0.0;
    return math.exp(logpdf(x));
  }

  @override
  double logpdf(double x) {
    if (x <= 0) return double.negativeInfinity;
    final d1 = df1;
    final d2 = df2;
    return (d1 / 2.0) * math.log(d1 / d2) +
        (d1 / 2.0 - 1.0) * math.log(x) -
        ((d1 + d2) / 2.0) * math.log(1.0 + d1 * x / d2) -
        lnBeta(d1 / 2.0, d2 / 2.0);
  }

  @override
  double cdf(double x) {
    if (x <= 0) return 0.0;
    final t = df1 * x / (df1 * x + df2);
    return regularizedIncompleteBeta(df1 / 2.0, df2 / 2.0, t);
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    final hi = distMean > 0 && distMean.isFinite
        ? distMean + 20.0 * distStdDev
        : 1000.0;
    return bisectInverseCdf(cdf, p, lo: 0.0, hi: hi < 1.0 ? 1.0 : hi);
  }

  @override
  String toString() => 'F(df1=$df1, df2=$df2)';
}
