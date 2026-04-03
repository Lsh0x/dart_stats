import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('ChiSquared distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final c = ChiSquared(df: 5.0);
        expect(c.df, 5.0);
      });

      test('df <= 0 throws', () {
        expect(
          () => ChiSquared(df: 0.0),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => ChiSquared(df: -1.0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('name is ChiSquared', () {
        expect(ChiSquared(df: 5).name, 'ChiSquared');
      });

      test('numParams is 1', () {
        expect(ChiSquared(df: 5).numParams, 1);
      });

      test('mean = df', () {
        expect(ChiSquared(df: 5.0).distMean, closeTo(5.0, 1e-10));
        expect(ChiSquared(df: 10.0).distMean, closeTo(10.0, 1e-10));
      });

      test('variance = 2*df', () {
        expect(ChiSquared(df: 5.0).distVariance, closeTo(10.0, 1e-10));
      });
    });

    group('pdf', () {
      test('pdf(x<=0) = 0', () {
        final c = ChiSquared(df: 5.0);
        expect(c.pdf(0.0), 0.0);
        expect(c.pdf(-1.0), 0.0);
      });

      test('df=2: pdf(x) = 0.5*exp(-x/2) (Exponential)', () {
        final c = ChiSquared(df: 2.0);
        expect(c.pdf(1.0), closeTo(0.5 * math.exp(-0.5), 1e-7));
      });

      test('df=5 pdf(4) from scipy', () {
        // scipy.stats.chi2.pdf(4, 5) ≈ 0.14397
        final c = ChiSquared(df: 5.0);
        expect(c.pdf(4.0), closeTo(0.14397, 1e-4));
      });
    });

    group('cdf', () {
      test('cdf(x<=0) = 0', () {
        final c = ChiSquared(df: 5.0);
        expect(c.cdf(0.0), 0.0);
      });

      test('cdf increases monotonically', () {
        final c = ChiSquared(df: 5.0);
        var prev = 0.0;
        for (var x = 0.5; x <= 20.0; x += 0.5) {
          final v = c.cdf(x);
          expect(v, greaterThanOrEqualTo(prev));
          prev = v;
        }
      });

      test('df=5 cdf(11.07) ≈ 0.95 (chi-square table)', () {
        final c = ChiSquared(df: 5.0);
        expect(c.cdf(11.07), closeTo(0.95, 0.005));
      });

      test('coherent with Gamma(df/2, 0.5)', () {
        final chi = ChiSquared(df: 8.0);
        final gam = GammaDistribution(alpha: 4.0, beta: 0.5);
        for (final x in [1.0, 4.0, 8.0, 12.0]) {
          expect(chi.cdf(x), closeTo(gam.cdf(x), 1e-10));
        }
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final c = ChiSquared(df: 10.0);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9, 0.95]) {
          expect(c.cdf(c.inverseCdf(p)), closeTo(p, 1e-5));
        }
      });
    });

    test('toString', () {
      expect(ChiSquared(df: 5.0).toString(), 'ChiSquared(df=5.0)');
    });
  });
}
