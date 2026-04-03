import 'dart:math' as math;

import '../errors.dart';
import '../utils/special_functions.dart';
import 'distribution.dart';

/// Student's t-distribution with [df] degrees of freedom.
///
/// PDF: f(x) = Gamma((df+1)/2) / (sqrt(df*pi) * Gamma(df/2))
///            * (1 + x^2/df)^(-(df+1)/2)
class StudentT extends Distribution {
  /// Creates a Student's t-distribution with [df] degrees of freedom.
  ///
  /// Throws [InvalidInputException] if [df] <= 0.
  StudentT({required this.df}) {
    if (df <= 0) {
      throw InvalidInputException('StudentT: df must be positive, got df=$df');
    }
  }

  /// Degrees of freedom (df > 0).
  final double df;

  @override
  String get name => 'StudentT';

  @override
  int get numParams => 1;

  @override
  double get distMean => df > 1 ? 0.0 : double.nan;

  @override
  double get distVariance {
    if (df > 2) return df / (df - 2.0);
    if (df > 1) return double.infinity;
    return double.nan;
  }

  @override
  double pdf(double x) => math.exp(logpdf(x));

  @override
  double logpdf(double x) {
    return lnGamma((df + 1.0) / 2.0) -
        0.5 * math.log(df * math.pi) -
        lnGamma(df / 2.0) -
        ((df + 1.0) / 2.0) * math.log(1.0 + x * x / df);
  }

  @override
  double cdf(double x) {
    // CDF(x) = 1/2 + x*Gamma((df+1)/2) / (sqrt(df*pi)*Gamma(df/2))
    //          * 2F1(1/2, (df+1)/2; 3/2; -x^2/df)
    // But simpler: use regularizedIncompleteBeta
    // CDF(x) = 1 - I_t(df/2, 1/2) / 2  where t = df/(df + x^2)
    // For x >= 0: CDF = 1 - I_t(df/2, 1/2) / 2
    // For x < 0:  CDF = I_t(df/2, 1/2) / 2
    final t = df / (df + x * x);
    final ib = regularizedIncompleteBeta(df / 2.0, 0.5, t);
    if (x >= 0) {
      return 1.0 - ib / 2.0;
    } else {
      return ib / 2.0;
    }
  }

  @override
  double inverseCdf(double p) {
    if (p <= 0 || p >= 1) {
      throw InvalidInputException('inverseCdf requires 0 < p < 1, got p=$p');
    }
    // Search range: for large df, t ≈ Normal, so ±40 is safe
    return bisectInverseCdf(cdf, p, lo: -1000.0, hi: 1000.0);
  }

  @override
  String toString() => 'StudentT(df=$df)';
}
