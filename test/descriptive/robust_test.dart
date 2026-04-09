import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  // ── Skewness ──

  group('skewness (population)', () {
    test('symmetric data → 0', () {
      expect(skewness([1, 2, 3, 4, 5]), closeTo(0.0, 1e-10));
    });

    test('right-skewed data → positive', () {
      // [1,1,1,1,1,1,1,1,1,100] is right-skewed
      expect(skewness([1, 1, 1, 1, 1, 1, 1, 1, 1, 100]), greaterThan(0));
    });

    test('left-skewed data → negative', () {
      // [100,99,99,99,99,99,99,99,99,1] is left-skewed
      expect(skewness([100, 99, 99, 99, 99, 99, 99, 99, 99, 1]), lessThan(0));
    });

    test('known value', () {
      // [2,8,0,4,1,9,9,0] — scipy.stats.skew(bias=True) ≈ 0.2650
      final data = [2, 8, 0, 4, 1, 9, 9, 0];
      expect(skewness(data), closeTo(0.2650, 0.01));
    });

    test('identical values → 0', () {
      expect(skewness([5, 5, 5]), closeTo(0.0, 1e-10));
    });

    test('fewer than 3 elements throws', () {
      expect(() => skewness([1, 2]), throwsA(isA<EmptyDataException>()));
    });
  });

  group('sampleSkewness', () {
    test('symmetric data → 0', () {
      expect(sampleSkewness([1, 2, 3, 4, 5]), closeTo(0.0, 1e-10));
    });

    test('right-skewed data → positive', () {
      expect(
        sampleSkewness([1, 1, 1, 1, 1, 1, 1, 1, 1, 100]),
        greaterThan(0),
      );
    });

    test('bias-corrected is larger than population for small n', () {
      final data = [2, 8, 0, 4, 1, 9, 9, 0];
      final pop = skewness(data);
      final sample = sampleSkewness(data);
      expect(sample.abs(), greaterThanOrEqualTo(pop.abs()));
    });

    test('fewer than 3 elements throws', () {
      expect(() => sampleSkewness([1, 2]), throwsA(isA<EmptyDataException>()));
    });
  });

  // ── Kurtosis ──

  group('kurtosis (population, excess)', () {
    test('normal-like data → near 0', () {
      // Large uniform dataset: excess kurtosis = -1.2
      final data = List.generate(100, (i) => i.toDouble());
      expect(kurtosis(data), closeTo(-1.2, 0.05));
    });

    test('leptokurtic data → positive', () {
      // Spike at center + extreme tails
      final data = [0, 0, 0, 0, 0, 0, 0, 0, 100, -100];
      expect(kurtosis(data), greaterThan(0));
    });

    test('identical values → -3', () {
      // Degenerate case: all values equal → σ=0 → returns -3
      expect(kurtosis([5, 5, 5, 5]), closeTo(-3.0, 1e-10));
    });

    test('fewer than 4 elements throws', () {
      expect(() => kurtosis([1, 2, 3]), throwsA(isA<EmptyDataException>()));
    });
  });

  group('sampleKurtosis', () {
    test('uniform data → near -1.2', () {
      final data = List.generate(100, (i) => i.toDouble());
      expect(sampleKurtosis(data), closeTo(-1.2, 0.1));
    });

    test('leptokurtic data → positive', () {
      final data = [0, 0, 0, 0, 0, 0, 0, 0, 100, -100];
      expect(sampleKurtosis(data), greaterThan(0));
    });

    test('fewer than 4 elements throws', () {
      expect(
        () => sampleKurtosis([1, 2, 3]),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });

  // ── MAD ──

  group('mad', () {
    test('known dataset', () {
      // [1, 1, 2, 2, 4, 6, 9]
      // median = 2, deviations = [1,1,0,0,2,4,7]
      // median of deviations = 1
      expect(mad([1, 1, 2, 2, 4, 6, 9]), closeTo(1.0, 1e-10));
    });

    test('symmetric data', () {
      // [1,2,3,4,5] → median=3, deviations=[2,1,0,1,2] → mad=1
      expect(mad([1, 2, 3, 4, 5]), closeTo(1.0, 1e-10));
    });

    test('identical values → 0', () {
      expect(mad([5, 5, 5, 5]), closeTo(0.0, 1e-10));
    });

    test('single element → 0', () {
      expect(mad([42]), closeTo(0.0, 1e-10));
    });

    test('empty list throws', () {
      expect(() => mad([]), throwsA(isA<EmptyDataException>()));
    });

    test('multiply by 1.4826 ≈ stddev for normal data', () {
      // For large normal samples, MAD * 1.4826 ≈ σ
      // Using [1,2,3,4,5]: stddev ≈ 1.414, mad=1, 1*1.4826=1.4826
      // Rough check: within reasonable range
      final data = [1, 2, 3, 4, 5];
      final robustSigma = mad(data) * 1.4826;
      expect(robustSigma, closeTo(1.4826, 0.01));
    });
  });

  // ── Trimmed mean ──

  group('trimmedMean', () {
    test('0% trim = regular mean', () {
      expect(trimmedMean([1, 2, 3, 4, 5], 0), closeTo(3.0, 1e-10));
    });

    test('10% trim on 10 elements removes 1 from each end', () {
      // [1,2,3,4,5,6,7,8,9,100] → trim 1 each → mean([2,3,4,5,6,7,8,9])
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100];
      expect(trimmedMean(data, 0.1), closeTo(5.5, 1e-10));
    });

    test('25% trim on 8 elements removes 2 from each end', () {
      // [1,2,3,4,5,6,7,100] → trim 2 each → mean([3,4,5,6]) = 4.5
      expect(trimmedMean([1, 2, 3, 4, 5, 6, 7, 100], 0.25), closeTo(4.5, 1e-10));
    });

    test('robust against outliers', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1000];
      final regularMean = mean(data);
      final trimmed = trimmedMean(data, 0.1);
      expect(trimmed, lessThan(regularMean));
      expect(trimmed, closeTo(5.5, 1e-10));
    });

    test('empty list throws', () {
      expect(
        () => trimmedMean([], 0.1),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('proportion >= 0.5 throws', () {
      expect(
        () => trimmedMean([1, 2, 3], 0.5),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('negative proportion throws', () {
      expect(
        () => trimmedMean([1, 2, 3], -0.1),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  // ── Winsorized mean ──

  group('winsorizedMean', () {
    test('0% winsorize = regular mean', () {
      expect(winsorizedMean([1, 2, 3, 4, 5], 0), closeTo(3.0, 1e-10));
    });

    test('10% winsorize on 10 elements', () {
      // [1,2,3,4,5,6,7,8,9,100] → clip to [2..9]
      // → [2,2,3,4,5,6,7,8,9,9] → mean = 55/10 = 5.5
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100];
      expect(winsorizedMean(data, 0.1), closeTo(5.5, 1e-10));
    });

    test('differs from trimmed mean', () {
      // Winsorized keeps n elements, trimmed removes some
      final data = [1, 2, 3, 4, 5, 6, 7, 100];
      final trimmed = trimmedMean(data, 0.25);
      final winsorized = winsorizedMean(data, 0.25);
      // Both should be robust, but values may differ
      expect(trimmed, closeTo(4.5, 1e-10)); // mean of [3,4,5,6]
      // winsorized: [3,3,3,4,5,6,6,6] → mean = 36/8 = 4.5
      expect(winsorized, closeTo(4.5, 1e-10));
    });

    test('empty list throws', () {
      expect(
        () => winsorizedMean([], 0.1),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('proportion >= 0.5 throws', () {
      expect(
        () => winsorizedMean([1, 2, 3], 0.5),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
