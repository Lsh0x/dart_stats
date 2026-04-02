import 'dart:math' as math;

import '../errors.dart';

/// Returns true if [a] and [b] differ by less than [epsilon].
///
/// Default epsilon is 1e-10.
bool approxEqual(double a, double b, {double epsilon = 1e-10}) =>
    (a - b).abs() < epsilon;

/// Returns ln(x), throwing [InvalidInputException] if x ≤ 0.
double safeLog(double x) {
  if (x <= 0) {
    throw InvalidInputException(
      'safeLog requires x > 0, got x=$x',
    );
  }
  return math.log(x);
}
