import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('bootstrap', () {
    test('estimate is close to sample mean', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = bootstrap(data, mean, nResamples: 2000, seed: 42);
      expect(result.estimate, closeTo(5.5, 0.5));
    });

    test('CI contains true mean', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = bootstrap(data, mean, nResamples: 2000, seed: 42);
      expect(result.ciLower, lessThan(5.5));
      expect(result.ciUpper, greaterThan(5.5));
    });

    test('CI width decreases with larger samples', () {
      // Use same range [1..5] but repeat for larger sample
      final small = [1, 2, 3, 4, 5];
      final large = [
        for (var i = 0; i < 20; i++) ...[1, 2, 3, 4, 5],
      ];

      final rSmall = bootstrap(small, mean, nResamples: 1000, seed: 42);
      final rLarge = bootstrap(large, mean, nResamples: 1000, seed: 42);

      final widthSmall = rSmall.ciUpper - rSmall.ciLower;
      final widthLarge = rLarge.ciUpper - rLarge.ciLower;
      expect(widthLarge, lessThan(widthSmall));
    });

    test('works with median statistic', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100];
      final result = bootstrap(data, median, nResamples: 1000, seed: 42);
      // Median of this data is 5.5, bootstrap should be close
      expect(result.estimate, closeTo(5.5, 2.0));
    });

    test('seed gives reproducible results', () {
      final data = [1, 2, 3, 4, 5];
      final r1 = bootstrap(data, mean, nResamples: 500, seed: 123);
      final r2 = bootstrap(data, mean, nResamples: 500, seed: 123);
      expect(r1.estimate, closeTo(r2.estimate, 1e-10));
      expect(r1.ciLower, closeTo(r2.ciLower, 1e-10));
      expect(r1.ciUpper, closeTo(r2.ciUpper, 1e-10));
    });

    test('replicates list has correct length', () {
      final data = [1, 2, 3, 4, 5];
      final result = bootstrap(data, mean, nResamples: 500, seed: 42);
      expect(result.replicates.length, 500);
      expect(result.nResamples, 500);
    });

    test('replicates are sorted', () {
      final data = [1, 2, 3, 4, 5];
      final result = bootstrap(data, mean, nResamples: 100, seed: 42);
      for (var i = 1; i < result.replicates.length; i++) {
        expect(result.replicates[i], greaterThanOrEqualTo(result.replicates[i - 1]));
      }
    });

    test('standard error is positive', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = bootstrap(data, mean, nResamples: 500, seed: 42);
      expect(result.standardError, greaterThan(0));
    });

    test('confidence level is stored', () {
      final data = [1, 2, 3, 4, 5];
      final r90 = bootstrap(data, mean, confidenceLevel: 0.90, seed: 42);
      final r99 = bootstrap(data, mean, confidenceLevel: 0.99, seed: 42);
      expect(r90.confidenceLevel, 0.90);
      expect(r99.confidenceLevel, 0.99);
      // 99% CI should be wider than 90%
      expect(
        r99.ciUpper - r99.ciLower,
        greaterThan(r90.ciUpper - r90.ciLower),
      );
    });

    test('empty data throws', () {
      expect(
        () => bootstrap([], mean),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('invalid confidence level throws', () {
      expect(
        () => bootstrap([1, 2, 3], mean, confidenceLevel: 0),
        throwsA(isA<InvalidInputException>()),
      );
      expect(
        () => bootstrap([1, 2, 3], mean, confidenceLevel: 1),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
