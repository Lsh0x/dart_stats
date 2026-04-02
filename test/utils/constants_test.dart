import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Constants', () {
    test('pi matches dart:math', () {
      expect(pi, math.pi);
    });

    test('e matches dart:math', () {
      expect(e, math.e);
    });

    test('sqrt2 is correct', () {
      expect(sqrt2, closeTo(math.sqrt2, 1e-15));
    });

    test('sqrtPi is correct', () {
      expect(sqrtPi, closeTo(math.sqrt(math.pi), 1e-15));
    });

    test('sqrt2Pi is correct', () {
      expect(sqrt2Pi, closeTo(math.sqrt(2 * math.pi), 1e-15));
    });

    test('invSqrt2Pi is correct', () {
      expect(invSqrt2Pi, closeTo(1.0 / math.sqrt(2 * math.pi), 1e-15));
    });

    test('ln2Pi is correct', () {
      expect(ln2Pi, closeTo(math.log(2 * math.pi), 1e-15));
    });

    test('ln2 is correct', () {
      expect(ln2, closeTo(math.ln2, 1e-15));
    });
  });
}
