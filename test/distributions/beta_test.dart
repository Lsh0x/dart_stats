import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Beta distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final b = Beta(alpha: 2.0, beta: 5.0);
        expect(b.alpha, 2.0);
        expect(b.beta, 5.0);
      });

      test('alpha <= 0 throws', () {
        expect(
          () => Beta(alpha: 0.0, beta: 1.0),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('beta <= 0 throws', () {
        expect(
          () => Beta(alpha: 1.0, beta: 0.0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('name is Beta', () {
        expect(Beta(alpha: 2, beta: 3).name, 'Beta');
      });

      test('numParams is 2', () {
        expect(Beta(alpha: 2, beta: 3).numParams, 2);
      });

      test('mean = alpha / (alpha + beta)', () {
        final b = Beta(alpha: 2.0, beta: 5.0);
        expect(b.distMean, closeTo(2.0 / 7.0, 1e-10));
      });

      test('variance formula', () {
        final b = Beta(alpha: 2.0, beta: 5.0);
        const expected = (2.0 * 5.0) / (7.0 * 7.0 * 8.0);
        expect(b.distVariance, closeTo(expected, 1e-10));
      });

      test('symmetric Beta(a,a) has mean 0.5', () {
        final b = Beta(alpha: 3.0, beta: 3.0);
        expect(b.distMean, closeTo(0.5, 1e-10));
      });
    });

    group('pdf', () {
      test('pdf outside [0,1] = 0', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        expect(b.pdf(-0.1), 0.0);
        expect(b.pdf(0.0), 0.0);
        expect(b.pdf(1.0), 0.0);
        expect(b.pdf(1.1), 0.0);
      });

      test('Beta(1,1) = Uniform: pdf ≈ 1', () {
        final b = Beta(alpha: 1.0, beta: 1.0);
        expect(b.pdf(0.3), closeTo(1.0, 1e-10));
        expect(b.pdf(0.7), closeTo(1.0, 1e-10));
      });

      test('Beta(2,2) symmetric: pdf(0.5) is max', () {
        final b = Beta(alpha: 2.0, beta: 2.0);
        final atHalf = b.pdf(0.5);
        expect(b.pdf(0.3), lessThan(atHalf));
        expect(b.pdf(0.7), lessThan(atHalf));
      });

      test('Beta(2,5) pdf(0.2) from scipy', () {
        // scipy.stats.beta.pdf(0.2, 2, 5) ≈ 2.4576
        final b = Beta(alpha: 2.0, beta: 5.0);
        expect(b.pdf(0.2), closeTo(2.4576, 1e-3));
      });
    });

    group('logpdf', () {
      test('logpdf outside [0,1] = -inf', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        expect(b.logpdf(-0.1), double.negativeInfinity);
        expect(b.logpdf(1.1), double.negativeInfinity);
      });

      test('logpdf(x) == ln(pdf(x))', () {
        final b = Beta(alpha: 3.0, beta: 2.0);
        for (final x in [0.1, 0.3, 0.5, 0.7, 0.9]) {
          expect(b.logpdf(x), closeTo(math.log(b.pdf(x)), 1e-10));
        }
      });
    });

    group('cdf', () {
      test('cdf(0) = 0, cdf(1) = 1', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        expect(b.cdf(0.0), 0.0);
        expect(b.cdf(1.0), 1.0);
      });

      test('Beta(1,1) cdf(x) = x (uniform)', () {
        final b = Beta(alpha: 1.0, beta: 1.0);
        expect(b.cdf(0.3), closeTo(0.3, 1e-7));
        expect(b.cdf(0.7), closeTo(0.7, 1e-7));
      });

      test('Beta(2,2) cdf(0.5) = 0.5 (symmetric)', () {
        final b = Beta(alpha: 2.0, beta: 2.0);
        expect(b.cdf(0.5), closeTo(0.5, 1e-7));
      });

      test('Beta(2,5) cdf(0.3) from scipy', () {
        // scipy.stats.beta.cdf(0.3, 2, 5) ≈ 0.5798235
        final b = Beta(alpha: 2.0, beta: 5.0);
        expect(b.cdf(0.3), closeTo(0.5798235, 1e-5));
      });

      test('cdf increases monotonically', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        var prev = 0.0;
        for (var x = 0.05; x <= 0.95; x += 0.05) {
          final c = b.cdf(x);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final b = Beta(alpha: 2.0, beta: 5.0);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(b.cdf(b.inverseCdf(p)), closeTo(p, 1e-6));
        }
      });

      test('Beta(2,2) inverseCdf(0.5) = 0.5', () {
        final b = Beta(alpha: 2.0, beta: 2.0);
        expect(b.inverseCdf(0.5), closeTo(0.5, 1e-6));
      });

      test('p out of range throws', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        expect(() => b.inverseCdf(0.0), throwsA(isA<InvalidInputException>()));
        expect(() => b.inverseCdf(1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    group('fit', () {
      test('fit recovers parameters from beta-like data', () {
        final data = [
          0.15,
          0.22,
          0.18,
          0.31,
          0.25,
          0.19,
          0.28,
          0.14,
          0.33,
          0.21,
          0.27,
          0.16,
          0.24,
          0.29,
          0.20,
          0.17,
          0.26,
          0.23,
          0.30,
          0.12,
        ];
        final fitted = Beta.fit(data);
        expect(fitted.alpha, greaterThan(0));
        expect(fitted.beta, greaterThan(0));
        expect(fitted.distMean, closeTo(mean(data), 0.05));
      });

      test('fit symmetric data → alpha ≈ beta', () {
        final data = [
          0.35,
          0.45,
          0.55,
          0.65,
          0.50,
          0.40,
          0.60,
          0.48,
          0.52,
          0.47,
        ];
        final fitted = Beta.fit(data);
        // Roughly symmetric around 0.5, alpha and beta should be close
        expect((fitted.alpha - fitted.beta).abs(), lessThan(1.5));
      });

      test('fit empty throws', () {
        expect(() => Beta.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit with values outside (0,1) throws', () {
        expect(
          () => Beta.fit([0.5, 1.0, 0.3]),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => Beta.fit([0.5, 0.0, 0.3]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('AIC / BIC', () {
      test('AIC = -2*LL + 2*k', () {
        final b = Beta(alpha: 2.0, beta: 3.0);
        final data = [0.1, 0.2, 0.3, 0.4, 0.5];
        final ll = b.logLikelihood(data);
        expect(b.aic(data), closeTo(-2 * ll + 4, 1e-10));
      });
    });

    test('toString', () {
      expect(
        Beta(alpha: 2.0, beta: 5.0).toString(),
        'Beta(alpha=2.0, beta=5.0)',
      );
    });
  });
}
