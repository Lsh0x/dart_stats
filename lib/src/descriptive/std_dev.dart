import 'dart:math' as math;

import 'variance.dart';

/// Population standard deviation of [data].
///
/// Returns `sqrt(variance(data))`.
/// Throws `EmptyDataException` if [data] is empty.
double stdDev(List<num> data) => math.sqrt(variance(data));

/// Sample standard deviation of [data].
///
/// Returns `sqrt(sampleVariance(data))`.
/// Throws `EmptyDataException` if [data] has fewer than 2 elements.
double sampleStdDev(List<num> data) => math.sqrt(sampleVariance(data));
