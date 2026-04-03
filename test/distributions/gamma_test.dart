import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Gamma distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.alpha, 2.0);
        expect(g.beta, 1.0);
      });

      test('alpha <= 0 throws', () {
        expect(
          () => GammaDistribution(alpha: 0.0, beta: 1.0),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => GammaDistribution(alpha: -1.0, beta: 1.0),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('beta <= 0 throws', () {
        expect(
          () => GammaDistribution(alpha: 1.0, beta: 0.0),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => GammaDistribution(alpha: 1.0, beta: -1.0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('name is Gamma', () {
        expect(GammaDistribution(alpha: 2, beta: 1).name, 'Gamma');
      });

      test('numParams is 2', () {
        expect(GammaDistribution(alpha: 2, beta: 1).numParams, 2);
      });

      test('mean = alpha / beta', () {
        final g = GammaDistribution(alpha: 3.0, beta: 2.0);
        expect(g.distMean, closeTo(1.5, 1e-10));
      });

      test('variance = alpha / beta^2', () {
        final g = GammaDistribution(alpha: 3.0, beta: 2.0);
        expect(g.distVariance, closeTo(0.75, 1e-10));
      });

      test('stdDev = sqrt(variance)', () {
        final g = GammaDistribution(alpha: 4.0, beta: 2.0);
        expect(g.distStdDev, closeTo(math.sqrt(1.0), 1e-10));
      });
    });

    group('pdf', () {
      test('pdf(x<=0) = 0', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.pdf(0.0), 0.0);
        expect(g.pdf(-1.0), 0.0);
      });

      test('shape=1 (Exponential): pdf(x) = exp(-x)', () {
        // Gamma(1, 1) = Exponential(1)
        final g = GammaDistribution(alpha: 1.0, beta: 1.0);
        expect(g.pdf(1.0), closeTo(0.36787944117, 1e-7));
        expect(g.pdf(2.0), closeTo(0.13533528324, 1e-7));
      });

      test('shape=2, rate=1: pdf(1) = exp(-1)', () {
        // Gamma(2,1): pdf(x) = x * exp(-x)
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.pdf(1.0), closeTo(0.36787944117, 1e-7));
      });

      test('shape=5, rate=1: pdf(4) from scipy', () {
        // scipy.stats.gamma.pdf(4, a=5, scale=1) ≈ 0.19536681482
        final g = GammaDistribution(alpha: 5.0, beta: 1.0);
        expect(g.pdf(4.0), closeTo(0.19536681482, 1e-7));
      });

      test('shape<1: pdf diverges near 0', () {
        final g = GammaDistribution(alpha: 0.5, beta: 1.0);
        expect(g.pdf(0.01), greaterThan(5.0));
      });
    });

    group('logpdf', () {
      test('logpdf(x<=0) = -inf', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.logpdf(0.0), double.negativeInfinity);
        expect(g.logpdf(-1.0), double.negativeInfinity);
      });

      test('logpdf(x) == ln(pdf(x))', () {
        final g = GammaDistribution(alpha: 3.0, beta: 2.0);
        for (final x in [0.5, 1.0, 2.0, 5.0]) {
          expect(g.logpdf(x), closeTo(math.log(g.pdf(x)), 1e-10));
        }
      });
    });

    group('cdf', () {
      test('cdf(x<=0) = 0', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.cdf(0.0), 0.0);
        expect(g.cdf(-1.0), 0.0);
      });

      test('shape=1 (Exponential): cdf(x) = 1 - exp(-x)', () {
        final g = GammaDistribution(alpha: 1.0, beta: 1.0);
        expect(g.cdf(1.0), closeTo(0.63212055882, 1e-7));
        expect(g.cdf(2.0), closeTo(0.86466471676, 1e-7));
      });

      test('shape=2, rate=1: cdf(2) from scipy', () {
        // scipy.stats.gamma.cdf(2, a=2, scale=1) ≈ 0.593994150
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.cdf(2.0), closeTo(0.59399415029, 1e-7));
      });

      test('cdf increases monotonically', () {
        final g = GammaDistribution(alpha: 3.0, beta: 1.0);
        var prev = 0.0;
        for (var x = 0.5; x <= 10.0; x += 0.5) {
          final c = g.cdf(x);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });

      test('cdf approaches 1 for large x', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(g.cdf(20.0), closeTo(1.0, 1e-7));
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final g = GammaDistribution(alpha: 3.0, beta: 2.0);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9, 0.99]) {
          expect(g.cdf(g.inverseCdf(p)), closeTo(p, 1e-6));
        }
      });

      test('inverseCdf(0.5) for Gamma(1,1) = ln(2)', () {
        // Exponential(1) median = ln(2)
        final g = GammaDistribution(alpha: 1.0, beta: 1.0);
        expect(g.inverseCdf(0.5), closeTo(math.ln2, 1e-6));
      });

      test('p out of range throws', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        expect(() => g.inverseCdf(0.0), throwsA(isA<InvalidInputException>()));
        expect(() => g.inverseCdf(1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    group('fit', () {
      test('fit recovers parameters from Gamma-like data', () {
        final data = [
          0.82,
          1.12,
          1.45,
          0.98,
          1.67,
          1.23,
          1.89,
          1.34,
          1.56,
          1.01,
          1.78,
          0.95,
          1.43,
          1.11,
          1.65,
          1.28,
          1.52,
          1.38,
          0.88,
          1.71,
        ];
        final fitted = GammaDistribution.fit(data);
        expect(fitted.alpha, greaterThan(0));
        expect(fitted.beta, greaterThan(0));
        // MLE guarantees fitted mean == data mean
        expect(fitted.distMean, closeTo(mean(data), 1e-10));
      });

      test('fit with exponential-like data (shape near 1)', () {
        final data = [0.2, 0.5, 0.1, 1.5, 0.8, 0.3, 2.1, 0.4, 0.7, 1.2];
        final fitted = GammaDistribution.fit(data);
        expect(fitted.alpha, greaterThan(0));
        expect(fitted.beta, greaterThan(0));
        expect(fitted.distMean, closeTo(mean(data), 1e-10));
      });

      test('fit empty throws', () {
        expect(
          () => GammaDistribution.fit([]),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('fit with non-positive values throws', () {
        expect(
          () => GammaDistribution.fit([1.0, -2.0, 3.0]),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => GammaDistribution.fit([1.0, 0.0, 3.0]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('AIC / BIC', () {
      test('AIC = -2*LL + 2*k', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final ll = g.logLikelihood(data);
        expect(g.aic(data), closeTo(-2 * ll + 4, 1e-10));
      });

      test('BIC = -2*LL + k*ln(n)', () {
        final g = GammaDistribution(alpha: 2.0, beta: 1.0);
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final ll = g.logLikelihood(data);
        expect(g.bic(data), closeTo(-2 * ll + 2 * math.log(5), 1e-10));
      });
    });

    test('toString', () {
      final g = GammaDistribution(alpha: 2.0, beta: 3.0);
      expect(g.toString(), 'Gamma(alpha=2.0, beta=3.0)');
    });
  });
}
