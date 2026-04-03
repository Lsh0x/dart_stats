import '../errors.dart';
import 'average.dart';
import 'std_dev.dart';

/// Z-score of [x] given [avg] and [sd] (standard deviation).
///
/// Returns (x - avg) / sd.
/// Throws [InvalidInputException] if [sd] ≤ 0.
double zScore(double x, double avg, double sd) {
  if (sd <= 0) {
    throw InvalidInputException(
      'Standard deviation must be positive, got sd=$sd',
    );
  }
  return (x - avg) / sd;
}

/// Computes z-scores for all elements of [data].
///
/// Uses population mean and population standard deviation.
/// Throws [EmptyDataException] if [data] is empty.
List<double> zScores(List<num> data) {
  if (data.isEmpty) {
    throw const EmptyDataException('Cannot compute z-scores of empty list');
  }
  final avg = mean(data);
  final sd = stdDev(data);
  if (sd == 0) {
    return List.filled(data.length, 0.0);
  }
  return [for (final x in data) (x - avg) / sd];
}
