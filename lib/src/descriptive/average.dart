import '../errors.dart';

/// Arithmetic mean of [data].
///
/// Throws [EmptyDataException] if [data] is empty.
double mean(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute mean of empty list');
  }
  var sum = 0.0;
  for (final x in data) {
    sum += x;
  }
  return sum / data.length;
}
