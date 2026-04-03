import '../distributions/chi_squared.dart';
import '../errors.dart';

/// Result of a chi-square test.
class ChiSquareResult {
  /// Creates a [ChiSquareResult].
  const ChiSquareResult({
    required this.statistic,
    required this.degreesOfFreedom,
    required this.pValue,
  });

  /// Chi-square statistic.
  final double statistic;

  /// Degrees of freedom.
  final int degreesOfFreedom;

  /// p-value.
  final double pValue;

  @override
  String toString() =>
      'ChiSquareResult(χ²=$statistic, df=$degreesOfFreedom, p=$pValue)';
}

/// Chi-square goodness-of-fit test.
///
/// Tests whether [observed] frequencies match [expected] frequencies.
/// Both lists must have the same length; expected values must be positive.
///
/// Degrees of freedom = length - 1.
ChiSquareResult chiSquareGoodnessOfFit(List<num> observed, List<num> expected) {
  if (observed.isEmpty) {
    throw const EmptyDataException(
      'chiSquareGoodnessOfFit: observed cannot be empty',
    );
  }
  if (expected.isEmpty) {
    throw const EmptyDataException(
      'chiSquareGoodnessOfFit: expected cannot be empty',
    );
  }
  if (observed.length != expected.length) {
    throw DimensionMismatchException(
      'chiSquareGoodnessOfFit: observed and expected must have same length '
      '(got ${observed.length} and ${expected.length})',
    );
  }

  var chi2 = 0.0;
  for (var i = 0; i < observed.length; i++) {
    final exp = expected[i].toDouble();
    if (exp <= 0) {
      throw InvalidInputException(
        'chiSquareGoodnessOfFit: expected values must be positive '
        '(got $exp at index $i)',
      );
    }
    final diff = observed[i].toDouble() - exp;
    chi2 += (diff * diff) / exp;
  }

  final df = observed.length - 1;
  final pValue = df > 0 ? 1.0 - ChiSquared(df: df.toDouble()).cdf(chi2) : 0.0;

  return ChiSquareResult(statistic: chi2, degreesOfFreedom: df, pValue: pValue);
}

/// Chi-square test of independence.
///
/// Tests whether rows and columns of a contingency table [matrix] are
/// independent. The matrix is a list of rows, each row a list of observed
/// counts. All rows must have the same length.
///
/// Degrees of freedom = (rows - 1) × (cols - 1).
ChiSquareResult chiSquareIndependence(List<List<num>> matrix) {
  if (matrix.isEmpty) {
    throw const EmptyDataException(
      'chiSquareIndependence: matrix cannot be empty',
    );
  }

  final rowCount = matrix.length;
  final colCount = matrix[0].length;

  for (var i = 0; i < rowCount; i++) {
    if (matrix[i].length != colCount) {
      throw DimensionMismatchException(
        'chiSquareIndependence: all rows must have same length '
        '(row $i has ${matrix[i].length}, expected $colCount)',
      );
    }
  }

  // Row sums, col sums, total
  final rowSums = List<double>.filled(rowCount, 0.0);
  final colSums = List<double>.filled(colCount, 0.0);
  var total = 0.0;

  for (var i = 0; i < rowCount; i++) {
    for (var j = 0; j < colCount; j++) {
      final v = matrix[i][j].toDouble();
      rowSums[i] += v;
      colSums[j] += v;
      total += v;
    }
  }

  // Chi-square statistic
  var chi2 = 0.0;
  for (var i = 0; i < rowCount; i++) {
    for (var j = 0; j < colCount; j++) {
      final exp = (rowSums[i] * colSums[j]) / total;
      if (exp <= 0) {
        throw InvalidInputException(
          'chiSquareIndependence: expected frequency must be positive '
          '(got $exp at row $i, col $j)',
        );
      }
      final diff = matrix[i][j].toDouble() - exp;
      chi2 += (diff * diff) / exp;
    }
  }

  final df = (rowCount - 1) * (colCount - 1);
  final pValue = df > 0 ? 1.0 - ChiSquared(df: df.toDouble()).cdf(chi2) : 0.0;

  return ChiSquareResult(statistic: chi2, degreesOfFreedom: df, pValue: pValue);
}
