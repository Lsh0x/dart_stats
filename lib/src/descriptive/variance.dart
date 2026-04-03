import '../errors.dart';

/// Population variance of [data] using Welford's one-pass algorithm.
///
/// Divides by n. Throws [EmptyDataException] if [data] is empty.
double variance(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute variance of empty list');
  }
  var mean = 0.0;
  var m2 = 0.0;
  for (var i = 0; i < data.length; i++) {
    final x = data[i].toDouble();
    final delta = x - mean;
    mean += delta / (i + 1);
    final delta2 = x - mean;
    m2 += delta * delta2;
  }
  return m2 / data.length;
}

/// Sample variance of [data] using Welford's one-pass algorithm.
///
/// Divides by (n-1) (Bessel's correction).
/// Throws [EmptyDataException] if [data] has fewer than 2 elements.
double sampleVariance(List<num> data) {
  if (data.length < 2) {
    throw const EmptyDataException(
      'Sample variance requires at least 2 elements',
    );
  }
  var mean = 0.0;
  var m2 = 0.0;
  for (var i = 0; i < data.length; i++) {
    final x = data[i].toDouble();
    final delta = x - mean;
    mean += delta / (i + 1);
    final delta2 = x - mean;
    m2 += delta * delta2;
  }
  return m2 / (data.length - 1);
}
