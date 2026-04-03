import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('zScore', () {
    test('at mean → 0', () {
      expect(zScore(100, 100, 15), closeTo(0.0, 1e-10));
    });

    test('one std dev above → 1', () {
      expect(zScore(115, 100, 15), closeTo(1.0, 1e-10));
    });

    test('two std devs below → -2', () {
      expect(zScore(70, 100, 15), closeTo(-2.0, 1e-10));
    });

    test('stdDev == 0 throws', () {
      expect(() => zScore(100, 100, 0), throwsA(isA<InvalidInputException>()));
    });

    test('negative stdDev throws', () {
      expect(() => zScore(100, 100, -1), throwsA(isA<InvalidInputException>()));
    });
  });

  group('zScores (batch)', () {
    test('normalizes a dataset', () {
      final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      final scores = zScores(data);
      // Mean of z-scores should be ~0
      expect(mean(scores), closeTo(0.0, 1e-10));
    });

    test('empty list throws', () {
      expect(() => zScores([]), throwsA(isA<EmptyDataException>()));
    });
  });
}
