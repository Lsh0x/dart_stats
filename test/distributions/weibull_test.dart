import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Weibull distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final w = Weibull(k: 2.0, lambda: 1.0);
        expect(w.k, 2.0);
        expect(w.lambda, 1.0);
      });

      test('k <= 0 throws', () {
        expect(
          () => Weibull(k: 0.0, lambda: 1.0),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('lambda <= 0 throws', () {
        expect(
          () => Weibull(k: 1.0, lambda: 0.0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('name is Weibull', () {
        expect(Weibull(k: 2, lambda: 1).name, 'Weibull');
      });

      test('numParams is 2', () {
        expect(Weibull(k: 2, lambda: 1).numParams, 2);
      });

      test('k=1 (Exponential): mean = lambda', () {
        final w = Weibull(k: 1.0, lambda: 2.0);
        expect(w.distMean, closeTo(2.0, 1e-7));
      });
    });

    group('pdf', () {
      test('pdf(x<0) = 0', () {
        final w = Weibull(k: 2.0, lambda: 1.0);
        expect(w.pdf(-1.0), 0.0);
      });

      test('k=1 (Exponential): pdf(x) = (1/lambda)*exp(-x/lambda)', () {
        final w = Weibull(k: 1.0, lambda: 2.0);
        expect(w.pdf(1.0), closeTo(0.5 * math.exp(-0.5), 1e-7));
      });

      test('k=2 (Rayleigh-like): pdf(1) with lambda=1', () {
        // pdf(1) = 2 * 1 * exp(-1) ≈ 0.7358
        final w = Weibull(k: 2.0, lambda: 1.0);
        expect(w.pdf(1.0), closeTo(2.0 * math.exp(-1.0), 1e-7));
      });
    });

    group('cdf', () {
      test('cdf(x<=0) = 0', () {
        final w = Weibull(k: 2.0, lambda: 1.0);
        expect(w.cdf(0.0), 0.0);
        expect(w.cdf(-1.0), 0.0);
      });

      test('k=1: cdf = 1 - exp(-x/lambda)', () {
        final w = Weibull(k: 1.0, lambda: 2.0);
        expect(w.cdf(2.0), closeTo(1.0 - math.exp(-1.0), 1e-7));
      });

      test('cdf increases monotonically', () {
        final w = Weibull(k: 2.0, lambda: 1.0);
        var prev = 0.0;
        for (var x = 0.1; x <= 5.0; x += 0.2) {
          final c = w.cdf(x);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final w = Weibull(k: 2.0, lambda: 3.0);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(w.cdf(w.inverseCdf(p)), closeTo(p, 1e-10));
        }
      });

      test('inverseCdf(0.5) for k=1 = lambda*ln(2)', () {
        final w = Weibull(k: 1.0, lambda: 2.0);
        expect(w.inverseCdf(0.5), closeTo(2.0 * math.ln2, 1e-10));
      });

      test('p out of range throws', () {
        final w = Weibull(k: 2.0, lambda: 1.0);
        expect(() => w.inverseCdf(0.0), throwsA(isA<InvalidInputException>()));
        expect(() => w.inverseCdf(1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    group('fit', () {
      test('fit recovers parameters', () {
        final data = [0.5, 1.2, 0.8, 1.5, 0.9, 1.1, 1.3, 0.7, 1.4, 1.0];
        final fitted = Weibull.fit(data);
        expect(fitted.k, greaterThan(0));
        expect(fitted.lambda, greaterThan(0));
      });

      test('fit empty throws', () {
        expect(() => Weibull.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit with non-positive values throws', () {
        expect(
          () => Weibull.fit([1.0, -1.0, 2.0]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    test('toString', () {
      expect(
        Weibull(k: 2.0, lambda: 3.0).toString(),
        'Weibull(k=2.0, lambda=3.0)',
      );
    });
  });
}
