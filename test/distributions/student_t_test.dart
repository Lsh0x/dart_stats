import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('StudentT distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final t = StudentT(df: 5.0);
        expect(t.df, 5.0);
      });

      test('df <= 0 throws', () {
        expect(() => StudentT(df: 0.0), throwsA(isA<InvalidInputException>()));
        expect(() => StudentT(df: -1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    group('properties', () {
      test('name is StudentT', () {
        expect(StudentT(df: 5).name, 'StudentT');
      });

      test('numParams is 1', () {
        expect(StudentT(df: 5).numParams, 1);
      });

      test('mean = 0 for df > 1', () {
        expect(StudentT(df: 2.0).distMean, 0.0);
        expect(StudentT(df: 30.0).distMean, 0.0);
      });

      test('mean is NaN for df <= 1', () {
        expect(StudentT(df: 1.0).distMean, isNaN);
      });

      test('variance = df/(df-2) for df > 2', () {
        expect(StudentT(df: 5.0).distVariance, closeTo(5.0 / 3.0, 1e-10));
      });

      test('variance is infinity for 1 < df <= 2', () {
        expect(StudentT(df: 2.0).distVariance, double.infinity);
      });
    });

    group('pdf', () {
      test('pdf is symmetric', () {
        final t = StudentT(df: 5.0);
        expect(t.pdf(2.0), closeTo(t.pdf(-2.0), 1e-10));
      });

      test('pdf max at 0', () {
        final t = StudentT(df: 5.0);
        expect(t.pdf(0.0), greaterThan(t.pdf(1.0)));
        expect(t.pdf(0.0), greaterThan(t.pdf(-1.0)));
      });

      test('df=1 (Cauchy): pdf(0) = 1/pi', () {
        final t = StudentT(df: 1.0);
        expect(t.pdf(0.0), closeTo(1.0 / math.pi, 1e-7));
      });

      test('df=30 approaches Normal pdf', () {
        final t = StudentT(df: 30.0);
        final n = Normal(mu: 0, sigma: 1);
        // For large df, t ≈ N(0,1)
        expect(t.pdf(0.0), closeTo(n.pdf(0.0), 0.01));
        expect(t.pdf(1.0), closeTo(n.pdf(1.0), 0.01));
      });
    });

    group('cdf', () {
      test('cdf(0) = 0.5 (symmetric)', () {
        final t = StudentT(df: 5.0);
        expect(t.cdf(0.0), closeTo(0.5, 1e-7));
      });

      test('cdf increases monotonically', () {
        final t = StudentT(df: 5.0);
        var prev = 0.0;
        for (var x = -5.0; x <= 5.0; x += 0.5) {
          final c = t.cdf(x);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });

      test('df=5 cdf(2.015) ≈ 0.95 (t-table)', () {
        // t_{0.05, 5} ≈ 2.015
        final t = StudentT(df: 5.0);
        expect(t.cdf(2.015), closeTo(0.95, 0.005));
      });

      test('symmetry: cdf(-x) ≈ 1 - cdf(x)', () {
        final t = StudentT(df: 10.0);
        for (final x in [0.5, 1.0, 2.0, 3.0]) {
          expect(t.cdf(-x), closeTo(1.0 - t.cdf(x), 1e-7));
        }
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final t = StudentT(df: 10.0);
        for (final p in [0.025, 0.05, 0.1, 0.5, 0.9, 0.95, 0.975]) {
          expect(t.cdf(t.inverseCdf(p)), closeTo(p, 1e-5));
        }
      });

      test('inverseCdf(0.5) = 0', () {
        final t = StudentT(df: 5.0);
        expect(t.inverseCdf(0.5), closeTo(0.0, 1e-6));
      });

      test('p out of range throws', () {
        final t = StudentT(df: 5.0);
        expect(() => t.inverseCdf(0.0), throwsA(isA<InvalidInputException>()));
        expect(() => t.inverseCdf(1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    test('toString', () {
      expect(StudentT(df: 5.0).toString(), 'StudentT(df=5.0)');
    });
  });
}
