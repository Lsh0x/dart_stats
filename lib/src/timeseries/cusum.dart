import '../descriptive/average.dart';
import '../errors.dart';

/// Result of a CUSUM (Cumulative Sum Control Chart) computation.
class CusumResult {
  /// Upper cumulative sum values.
  final List<double> upper;

  /// Lower cumulative sum values.
  final List<double> lower;

  /// Indices where an upward shift was detected.
  final List<int> upwardChangePoints;

  /// Indices where a downward shift was detected.
  final List<int> downwardChangePoints;

  /// All change point indices (up + down, sorted).
  List<int> get changePoints {
    final all = [...upwardChangePoints, ...downwardChangePoints]..sort();
    return all;
  }

  /// Target value used.
  final double target;

  /// Threshold used for detection.
  final double threshold;

  const CusumResult({
    required this.upper,
    required this.lower,
    required this.upwardChangePoints,
    required this.downwardChangePoints,
    required this.target,
    required this.threshold,
  });
}

/// Computes a two-sided CUSUM control chart on [data].
///
/// Detects shifts (change points) in the mean of a process.
///
/// [target] is the in-control mean. If null, uses the mean of [data].
/// [threshold] is the decision interval (h). When the cumulative sum
/// exceeds h, a change point is flagged. Default: 4 × σ.
/// [slack] is the allowance (k), typically σ/2. Default: σ/2.
///
/// Upper CUSUM: S_t⁺ = max(0, x_t − (target + k) + S_{t−1}⁺)
/// Lower CUSUM: S_t⁻ = max(0, (target − k) − x_t + S_{t−1}⁻)
///
/// Throws [EmptyDataException] if [data] has fewer than 2 elements.
CusumResult cusum(
  List<num> data, {
  double? target,
  double? threshold,
  double? slack,
}) {
  if (data.length < 2) {
    throw const EmptyDataException(
      'CUSUM requires at least 2 data points',
    );
  }

  final mu = target ?? mean(data);

  // Estimate σ from data (using mean absolute deviation as quick estimate)
  var sumAbsDev = 0.0;
  for (final x in data) {
    sumAbsDev += (x - mu).abs();
  }
  final sigma = sumAbsDev / data.length;
  if (sigma == 0) {
    // Constant data, no change points
    return CusumResult(
      upper: List.filled(data.length, 0),
      lower: List.filled(data.length, 0),
      upwardChangePoints: [],
      downwardChangePoints: [],
      target: mu,
      threshold: threshold ?? 0,
    );
  }

  final k = slack ?? sigma / 2;
  final h = threshold ?? 4 * sigma;

  final upper = <double>[0.0];
  final lower = <double>[0.0];
  final upPoints = <int>[];
  final downPoints = <int>[];

  for (var i = 1; i < data.length; i++) {
    final x = data[i].toDouble();

    // Upper CUSUM (detect upward shift)
    final sUp = upper[i - 1] + x - mu - k;
    upper.add(sUp > 0 ? sUp : 0.0);

    // Lower CUSUM (detect downward shift)
    final sDown = lower[i - 1] + mu - k - x;
    lower.add(sDown > 0 ? sDown : 0.0);

    // Check thresholds
    if (upper[i] > h) {
      upPoints.add(i);
      upper[i] = 0.0; // reset after detection
    }
    if (lower[i] > h) {
      downPoints.add(i);
      lower[i] = 0.0; // reset after detection
    }
  }

  return CusumResult(
    upper: upper,
    lower: lower,
    upwardChangePoints: upPoints,
    downwardChangePoints: downPoints,
    target: mu,
    threshold: h,
  );
}
