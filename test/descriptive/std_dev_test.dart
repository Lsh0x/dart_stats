import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('stdDev (population)', () {
    test('equals sqrt(variance)', () {
      final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      expect(stdDev(data), closeTo(math.sqrt(4.0), 1e-10));
    });

    test('identical values → 0', () {
      expect(stdDev([3, 3, 3]), closeTo(0.0, 1e-10));
    });

    test('empty list throws', () {
      expect(() => stdDev([]), throwsA(isA<EmptyDataException>()));
    });
  });

  group('sampleStdDev', () {
    test('equals sqrt(sampleVariance)', () {
      final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      expect(sampleStdDev(data), closeTo(math.sqrt(32.0 / 7.0), 1e-10));
    });

    test('single element throws', () {
      expect(() => sampleStdDev([42]), throwsA(isA<EmptyDataException>()));
    });
  });
}
