import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('stdErr', () {
    test('formula: sampleStdDev / sqrt(n)', () {
      final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      final expected = sampleStdDev(data) / math.sqrt(data.length);
      expect(stdErr(data), closeTo(expected, 1e-10));
    });

    test('larger sample → smaller error', () {
      final small = [1.0, 2.0, 3.0];
      final large = [1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0];
      expect(stdErr(large), lessThan(stdErr(small)));
    });

    test('needs at least 2 elements', () {
      expect(() => stdErr([42]), throwsA(isA<EmptyDataException>()));
    });

    test('empty list throws', () {
      expect(() => stdErr([]), throwsA(isA<EmptyDataException>()));
    });
  });
}
