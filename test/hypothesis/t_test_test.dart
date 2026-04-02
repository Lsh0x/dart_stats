import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('oneSampleTTest', () {
    test('sample mean equals mu → pValue ≈ 1', () {
      final data = [10.0, 10.0, 10.0, 10.0, 10.0];
      final result = oneSampleTTest(data, 10.0);
      expect(result.tStatistic, closeTo(0.0, 1e-10));
      expect(result.pValue, closeTo(1.0, 1e-4));
    });

    test('significant difference', () {
      // Mean ≈ 105, testing against mu=100
      final data = [102.0, 104.0, 106.0, 108.0, 105.0];
      final result = oneSampleTTest(data, 100.0);
      expect(result.tStatistic, greaterThan(2.0));
      expect(result.pValue, lessThan(0.05));
      expect(result.degreesOfFreedom, 4);
    });

    test('empty data throws', () {
      expect(
        () => oneSampleTTest([], 0),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('single element throws (no variance)', () {
      expect(
        () => oneSampleTTest([5.0], 0),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('result contains all fields', () {
      final result = oneSampleTTest([1.0, 2.0, 3.0, 4.0, 5.0], 3.0);
      expect(result.tStatistic, isA<double>());
      expect(result.pValue, isA<double>());
      expect(result.degreesOfFreedom, isA<int>());
      expect(result.meanDiff, isA<double>());
      expect(result.stdError, isA<double>());
    });
  });

  group('pairedTTest', () {
    test('identical pairs → pValue ≈ 1', () {
      final before = [10.0, 20.0, 30.0, 40.0, 50.0];
      final after = [10.0, 20.0, 30.0, 40.0, 50.0];
      final result = pairedTTest(before, after);
      expect(result.tStatistic, closeTo(0.0, 1e-10));
      expect(result.pValue, closeTo(1.0, 1e-4));
    });

    test('significant improvement', () {
      final before = [200.0, 210.0, 220.0, 215.0, 205.0, 225.0];
      final after = [180.0, 185.0, 190.0, 195.0, 180.0, 200.0];
      final result = pairedTTest(before, after);
      expect(result.pValue, lessThan(0.05));
      expect(result.meanDiff, greaterThan(0));
      expect(result.degreesOfFreedom, 5);
    });

    test('constant difference → very significant', () {
      final before = [10.0, 20.0, 30.0, 40.0, 50.0];
      final after = [15.0, 25.0, 35.0, 45.0, 55.0];
      final result = pairedTTest(before, after);
      // All diffs are exactly -5, stddev of diffs = 0
      // t should be -Infinity or very large, pValue ≈ 0
      expect(result.pValue, lessThan(0.001));
    });

    test('different lengths throws', () {
      expect(
        () => pairedTTest([1, 2, 3], [1, 2]),
        throwsA(isA<DimensionMismatchException>()),
      );
    });

    test('empty throws', () {
      expect(
        () => pairedTTest([], []),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('single pair throws', () {
      expect(
        () => pairedTTest([1], [2]),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });

  group('twoSampleTTest', () {
    test('identical samples → pValue ≈ 1', () {
      final a = [10.0, 20.0, 30.0, 40.0, 50.0];
      final b = [10.0, 20.0, 30.0, 40.0, 50.0];
      final result = twoSampleTTest(a, b);
      expect(result.tStatistic, closeTo(0.0, 1e-10));
      expect(result.pValue, closeTo(1.0, 1e-4));
    });

    test('significantly different means', () {
      final a = [100.0, 102.0, 104.0, 103.0, 101.0];
      final b = [200.0, 202.0, 204.0, 203.0, 201.0];
      final result = twoSampleTTest(a, b);
      expect(result.pValue, lessThan(0.001));
    });

    test('empty first sample throws', () {
      expect(
        () => twoSampleTTest([], [1, 2, 3]),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('empty second sample throws', () {
      expect(
        () => twoSampleTTest([1, 2, 3], []),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });
}
