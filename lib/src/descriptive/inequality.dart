import '../errors.dart';

/// Gini coefficient of [data].
///
/// Measures statistical dispersion / inequality.
/// Gini = 0 → perfect equality (all values identical).
/// Gini = 1 → maximum inequality (one value holds everything).
///
/// Uses the formula: G = (2 × Σ i × x_i) / (n × Σ x_i) − (n + 1) / n
/// where x_i are sorted ascending.
///
/// All values must be non-negative.
///
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if any value is negative.
double gini(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute Gini of empty list');
  }

  for (final x in data) {
    if (x < 0) {
      throw InvalidInputException(
        'Gini coefficient requires non-negative values, got $x',
      );
    }
  }

  final sorted = [...data]..sort();
  final n = sorted.length;

  var totalSum = 0.0;
  var weightedSum = 0.0;
  for (var i = 0; i < n; i++) {
    totalSum += sorted[i];
    weightedSum += (i + 1) * sorted[i];
  }

  if (totalSum == 0) return 0.0; // all zeros = perfect equality

  return (2 * weightedSum) / (n * totalSum) - (n + 1) / n;
}
