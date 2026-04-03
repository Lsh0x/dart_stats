import '../errors.dart';
import 'gamma.dart';

/// Chi-squared distribution with [df] degrees of freedom.
///
/// This is a special case of Gamma(df/2, 1/2).
class ChiSquared extends GammaDistribution {
  /// Creates a Chi-squared distribution with [df] degrees of freedom.
  ///
  /// Throws [InvalidInputException] if [df] <= 0.
  ChiSquared({required this.df}) : super(alpha: df / 2.0, beta: 0.5) {
    if (df <= 0) {
      throw InvalidInputException(
        'ChiSquared: df must be positive, got df=$df',
      );
    }
  }

  /// Degrees of freedom.
  final double df;

  @override
  String get name => 'ChiSquared';

  @override
  int get numParams => 1;

  /// Mean = df.
  @override
  double get distMean => df;

  /// Variance = 2 * df.
  @override
  double get distVariance => 2.0 * df;

  @override
  String toString() => 'ChiSquared(df=$df)';
}
