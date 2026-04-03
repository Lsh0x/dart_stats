import 'dart:math' as math;

import '../errors.dart';
import '../utils/matrix.dart';
import '../utils/special_functions.dart';
import 'linear_regression.dart';

/// Multiple linear regression model (OLS).
///
/// Fits y = β₀ + β₁x₁ + β₂x₂ + ... + βₖxₖ using normal equations:
/// β = (XᵀX)⁻¹Xᵀy
class MultipleLinearRegression {
  /// Creates a [MultipleLinearRegression] with precomputed values.
  const MultipleLinearRegression._({
    required this.coefficients,
    required this.intercept,
    required this.rSquared,
    required this.adjustedRSquared,
    required this.standardError,
    required this.residuals,
    required this.n,
    required this.p,
  });

  /// Fits a multiple regression to [x] (n×k matrix) and [y] (length n).
  ///
  /// Each row of [x] is one observation with k features.
  /// An intercept column is added automatically.
  factory MultipleLinearRegression.fit(List<List<num>> x, List<num> y) {
    if (x.isEmpty || y.isEmpty) {
      throw const EmptyDataException(
        'MultipleLinearRegression.fit requires non-empty data',
      );
    }
    if (x.length != y.length) {
      throw DimensionMismatchException(
        'x rows (${x.length}) must match y length (${y.length})',
      );
    }

    final n = x.length;
    final k = x[0].length;

    if (n < k + 1) {
      throw InvalidInputException(
        'MultipleLinearRegression: need at least ${k + 1} observations '
        'for $k predictors, got $n',
      );
    }

    for (var i = 0; i < n; i++) {
      if (x[i].length != k) {
        throw DimensionMismatchException(
          'All rows of x must have same length '
          '(row $i has ${x[i].length}, expected $k)',
        );
      }
    }

    // Design matrix X with intercept column [1, x1, x2, ..., xk]
    final xMat = List.generate(
      n,
      (i) => [1.0, ...x[i].map((v) => v.toDouble())],
    );
    final yVec = y.map((v) => v.toDouble()).toList();

    // β = (XᵀX)⁻¹ Xᵀy
    final xT = matTranspose(xMat);
    final xTx = matMultiply(xT, xMat);
    final xTxInv = matInverse(xTx);
    final xTy = matVecMultiply(xT, yVec);
    final beta = matVecMultiply(xTxInv, xTy);

    // Intercept = β₀, coefficients = [β₁, β₂, ..., βₖ]
    final intercept = beta[0];
    final coefficients = beta.sublist(1);

    // Residuals and SSE
    final residuals = List<double>.filled(n, 0.0);
    var sse = 0.0;
    for (var i = 0; i < n; i++) {
      var yHat = intercept;
      for (var j = 0; j < k; j++) {
        yHat += coefficients[j] * x[i][j].toDouble();
      }
      residuals[i] = yVec[i] - yHat;
      sse += residuals[i] * residuals[i];
    }

    // SST (total sum of squares)
    final yMean = yVec.fold(0.0, (a, b) => a + b) / n;
    var sst = 0.0;
    for (final yi in yVec) {
      sst += (yi - yMean) * (yi - yMean);
    }

    final rSquared = sst == 0 ? 0.0 : 1.0 - sse / sst;
    final adjustedRSquared = n - k - 1 > 0
        ? 1.0 - (1.0 - rSquared) * (n - 1) / (n - k - 1)
        : 0.0;
    final standardError = n - k - 1 > 0 ? math.sqrt(sse / (n - k - 1)) : 0.0;

    return MultipleLinearRegression._(
      coefficients: coefficients,
      intercept: intercept,
      rSquared: rSquared,
      adjustedRSquared: adjustedRSquared,
      standardError: standardError,
      residuals: residuals,
      n: n,
      p: k,
    );
  }

  /// Restores from JSON.
  factory MultipleLinearRegression.fromJson(Map<String, dynamic> json) {
    return MultipleLinearRegression._(
      coefficients: (json['coefficients'] as List).cast<double>(),
      intercept: (json['intercept'] as num).toDouble(),
      rSquared: (json['rSquared'] as num).toDouble(),
      adjustedRSquared: (json['adjustedRSquared'] as num).toDouble(),
      standardError: (json['standardError'] as num).toDouble(),
      residuals: (json['residuals'] as List).cast<double>(),
      n: json['n'] as int,
      p: json['p'] as int,
    );
  }

  /// Regression coefficients [β₁, β₂, ..., βₖ] (excluding intercept).
  final List<double> coefficients;

  /// Y-intercept (β₀).
  final double intercept;

  /// Coefficient of determination (R²).
  final double rSquared;

  /// Adjusted R² (penalizes for number of predictors).
  final double adjustedRSquared;

  /// Standard error of the regression.
  final double standardError;

  /// Residuals (y - ŷ) for each observation.
  final List<double> residuals;

  /// Number of observations.
  final int n;

  /// Number of predictors.
  final int p;

  /// Predicts y for a single observation [x].
  double predict(List<num> x) {
    if (x.length != p) {
      throw DimensionMismatchException(
        'predict: expected $p features, got ${x.length}',
      );
    }
    var yHat = intercept;
    for (var j = 0; j < p; j++) {
      yHat += coefficients[j] * x[j].toDouble();
    }
    return yHat;
  }

  /// Predicts y for multiple observations.
  List<double> predictMany(List<List<num>> xs) => [
    for (final x in xs) predict(x),
  ];

  /// Confidence interval for predicted mean at [x].
  ///
  /// [level] is the confidence level (e.g., 0.95).
  ConfidenceInterval confidenceInterval(List<num> x, double level) {
    final yHat = predict(x);
    final df = n - p - 1;
    if (df <= 0) {
      return ConfidenceInterval(lower: yHat, upper: yHat);
    }

    final alpha = 1.0 - level;
    final tCrit = _studentTInverseCdf(1.0 - alpha / 2.0, df);

    // Simplified SE of prediction (diagonal approximation)
    final se = standardError * math.sqrt(1.0 / n);
    return ConfidenceInterval(
      lower: yHat - tCrit * se,
      upper: yHat + tCrit * se,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'coefficients': coefficients,
    'intercept': intercept,
    'rSquared': rSquared,
    'adjustedRSquared': adjustedRSquared,
    'standardError': standardError,
    'residuals': residuals,
    'n': n,
    'p': p,
  };

  @override
  String toString() {
    final terms = <String>['${intercept.toStringAsFixed(4)}'];
    for (var i = 0; i < coefficients.length; i++) {
      terms.add('${coefficients[i].toStringAsFixed(4)}·x${i + 1}');
    }
    return 'MultipleLinearRegression(y = ${terms.join(' + ')}, '
        'R²=${rSquared.toStringAsFixed(4)})';
  }

  static double _studentTInverseCdf(double p, int df) {
    double tCdf(double t) {
      final x = df / (df + t * t);
      return 1.0 - 0.5 * regularizedIncompleteBeta(df / 2.0, 0.5, x);
    }

    return bisectInverseCdf(tCdf, p, lo: -100, hi: 100);
  }
}
