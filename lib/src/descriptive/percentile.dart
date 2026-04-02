import '../errors.dart';

/// Median (50th percentile) of [data].
///
/// Throws [EmptyDataException] if [data] is empty.
double median(List<num> data) => percentile(data, 0.5);

/// Interquartile range (Q3 - Q1) of [data].
///
/// Throws [EmptyDataException] if [data] is empty.
double iqr(List<num> data) => percentile(data, 0.75) - percentile(data, 0.25);

/// Returns the [p]-th percentile of [data] using linear interpolation.
///
/// [p] must be in [0, 1]. Uses the exclusive method (same as NumPy default).
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if [p] is outside [0, 1].
double percentile(List<num> data, double p) {
  if (data.isEmpty) {
    throw const EmptyDataException(
      'Cannot compute percentile of empty list',
    );
  }
  if (p < 0 || p > 1) {
    throw InvalidInputException(
      'Percentile p must be in [0, 1], got p=$p',
    );
  }

  final sorted = [...data]..sort();
  if (p == 0) return sorted.first.toDouble();
  if (p == 1) return sorted.last.toDouble();

  final n = sorted.length;
  final index = p * (n - 1);
  final lower = index.floor();
  final upper = index.ceil();

  if (lower == upper) return sorted[lower].toDouble();

  final fraction = index - lower;
  return sorted[lower] * (1 - fraction) + sorted[upper] * fraction;
}
