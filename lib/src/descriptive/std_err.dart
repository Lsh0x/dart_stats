import 'dart:math' as math;

import 'std_dev.dart';

/// Standard error of the mean for [data].
///
/// Computed as `sampleStdDev / sqrt(n)`.
/// Throws `EmptyDataException` if [data] has fewer than 2 elements.
double stdErr(List<num> data) => sampleStdDev(data) / math.sqrt(data.length);
