import 'dart:math' as math;

import '../descriptive/average.dart';
import '../errors.dart';
import '../utils/special_functions.dart';

/// Confidence interval bounds.
class ConfidenceInterval {
  /// Creates a [ConfidenceInterval].
  const ConfidenceInterval({required this.lower, required this.upper});

  /// Lower bound.
  final double lower;

  /// Upper bound.
  final double upper;

  @override
  String toString() => 'CI($lower, $upper)';
}

/// Simple linear regression model (OLS).
///
/// Fits y = slope * x + intercept using ordinary least squares.
class LinearRegression {
  /// Creates a [LinearRegression] with precomputed values.
  const LinearRegression._({
    required this.slope,
    required this.intercept,
    required this.rSquared,
    required this.standardError,
    required this.n,
    required double xMean,
    required double sxx,
  }) : _xMean = xMean,
       _sxx = sxx;

  /// Fits a linear regression model to ([x], [y]) data.
  ///
  /// Requires at least 2 points with matching lengths.
  factory LinearRegression.fit(List<num> x, List<num> y) {
    if (x.isEmpty || y.isEmpty) {
      throw const EmptyDataException(
        'LinearRegression.fit requires non-empty data',
      );
    }
    if (x.length != y.length) {
      throw DimensionMismatchException(
        'x and y must have same length, '
        'got ${x.length} and ${y.length}',
      );
    }
    if (x.length < 2) {
      throw const EmptyDataException(
        'LinearRegression.fit requires at least 2 data points',
      );
    }

    final n = x.length;
    final xMean = mean(x);
    final yMean = mean(y);

    var sxx = 0.0;
    var sxy = 0.0;
    var syy = 0.0;

    for (var i = 0; i < n; i++) {
      final dx = x[i].toDouble() - xMean;
      final dy = y[i].toDouble() - yMean;
      sxx += dx * dx;
      sxy += dx * dy;
      syy += dy * dy;
    }

    final slope = sxx == 0 ? 0.0 : sxy / sxx;
    final intercept = yMean - slope * xMean;

    // R-squared
    final rSquared = syy == 0 ? 0.0 : 1.0 - _sse(x, y, slope, intercept) / syy;

    // Standard error of the regression
    final sse = _sse(x, y, slope, intercept);
    final se = n > 2 ? math.sqrt(sse / (n - 2)) : 0.0;

    return LinearRegression._(
      slope: slope,
      intercept: intercept,
      rSquared: rSquared,
      standardError: se,
      n: n,
      xMean: xMean,
      sxx: sxx,
    );
  }

  /// Restores a [LinearRegression] from JSON.
  factory LinearRegression.fromJson(Map<String, dynamic> json) {
    return LinearRegression._(
      slope: (json['slope'] as num).toDouble(),
      intercept: (json['intercept'] as num).toDouble(),
      rSquared: (json['rSquared'] as num).toDouble(),
      standardError: (json['standardError'] as num).toDouble(),
      n: json['n'] as int,
      xMean: (json['xMean'] as num).toDouble(),
      sxx: (json['sxx'] as num).toDouble(),
    );
  }

  /// Slope of the regression line.
  final double slope;

  /// Y-intercept of the regression line.
  final double intercept;

  /// Coefficient of determination (R²). 0 = no fit, 1 = perfect.
  final double rSquared;

  /// Standard error of the regression (residual standard error).
  final double standardError;

  /// Number of data points used to fit.
  final int n;

  final double _xMean;
  final double _sxx;

  /// Pearson correlation coefficient (r).
  double get correlationCoefficient =>
      slope >= 0 ? math.sqrt(rSquared) : -math.sqrt(rSquared);

  /// Predicts y for a given [x].
  double predict(double x) => slope * x + intercept;

  /// Predicts y for multiple x values.
  List<double> predictMany(List<num> xs) => [
    for (final x in xs) predict(x.toDouble()),
  ];

  /// Confidence interval for the predicted mean at [x].
  ///
  /// [level] is the confidence level (e.g., 0.95 for 95%).
  /// Uses Student's t-distribution for the critical value.
  ConfidenceInterval confidenceInterval(double x, double level) {
    final df = n - 2;
    if (df <= 0) {
      final yHat = predict(x);
      return ConfidenceInterval(lower: yHat, upper: yHat);
    }

    // t critical value via bisection on Student-t CDF
    final alpha = 1.0 - level;
    final tCrit = _studentTInverseCdf(1.0 - alpha / 2.0, df);

    final dx = x - _xMean;
    final sePred = standardError * math.sqrt(1.0 / n + (dx * dx) / _sxx);

    final yHat = predict(x);
    return ConfidenceInterval(
      lower: yHat - tCrit * sePred,
      upper: yHat + tCrit * sePred,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'slope': slope,
    'intercept': intercept,
    'rSquared': rSquared,
    'standardError': standardError,
    'n': n,
    'xMean': _xMean,
    'sxx': _sxx,
  };

  @override
  String toString() =>
      'LinearRegression(y = ${slope.toStringAsFixed(4)}x + '
      '${intercept.toStringAsFixed(4)}, r²=${rSquared.toStringAsFixed(4)})';

  /// Sum of squared errors.
  static double _sse(List<num> x, List<num> y, double slope, double intercept) {
    var sse = 0.0;
    for (var i = 0; i < x.length; i++) {
      final residual = y[i].toDouble() - (slope * x[i].toDouble() + intercept);
      sse += residual * residual;
    }
    return sse;
  }

  /// Inverse CDF of Student's t-distribution using bisection.
  static double _studentTInverseCdf(double p, int df) {
    double tCdf(double t) {
      final x = df / (df + t * t);
      return 1.0 - 0.5 * regularizedIncompleteBeta(df / 2.0, 0.5, x);
    }

    return bisectInverseCdf(tCdf, p, lo: -100, hi: 100);
  }
}
