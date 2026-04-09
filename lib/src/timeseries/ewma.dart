import '../errors.dart';

/// Result of an EWMA (Exponentially Weighted Moving Average) computation.
class EwmaResult {
  /// Smoothed values (same length as input).
  final List<double> values;

  /// Smoothing factor used.
  final double alpha;

  const EwmaResult({required this.values, required this.alpha});
}

/// Computes the Exponentially Weighted Moving Average of [data].
///
/// EWMA_t = α × x_t + (1−α) × EWMA_{t-1}
///
/// [alpha] is the smoothing factor in (0, 1].
/// Higher alpha = more weight on recent observations.
/// The first value is initialized to data[0].
///
/// Throws [EmptyDataException] if [data] is empty.
/// Throws [InvalidInputException] if [alpha] is not in (0, 1].
EwmaResult ewma(List<num> data, {double alpha = 0.3}) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute EWMA of empty data');
  }
  if (alpha <= 0 || alpha > 1) {
    throw InvalidInputException(
      'Alpha must be in (0, 1], got $alpha',
    );
  }

  final values = <double>[data[0].toDouble()];
  for (var i = 1; i < data.length; i++) {
    values.add(alpha * data[i] + (1 - alpha) * values[i - 1]);
  }
  return EwmaResult(values: values, alpha: alpha);
}
