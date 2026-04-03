import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Normal distribution', () {
    late Normal std;

    setUp(() {
      std = Normal(mu: 0, sigma: 1);
    });

    group('construction', () {
      test('standard normal', () {
        expect(std.mu, 0);
        expect(std.sigma, 1);
      });

      test('custom parameters', () {
        final d = Normal(mu: 5, sigma: 2);
        expect(d.mu, 5);
        expect(d.sigma, 2);
      });

      test('sigma <= 0 throws', () {
        expect(
          () => Normal(mu: 0, sigma: 0),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => Normal(mu: 0, sigma: -1),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('mean equals mu', () {
        expect(Normal(mu: 5, sigma: 2).distMean, 5.0);
      });

      test('variance equals sigma^2', () {
        expect(Normal(mu: 0, sigma: 3).distVariance, closeTo(9.0, 1e-10));
      });

      test('stdDev equals sigma', () {
        expect(Normal(mu: 0, sigma: 3).distStdDev, closeTo(3.0, 1e-10));
      });

      test('name is Normal', () {
        expect(std.name, 'Normal');
      });

      test('numParams is 2', () {
        expect(std.numParams, 2);
      });
    });

    group('pdf', () {
      test('pdf(0) for standard normal ≈ 0.3989', () {
        expect(std.pdf(0), closeTo(0.39894228040143, 1e-10));
      });

      test('pdf is symmetric', () {
        expect(std.pdf(1), closeTo(std.pdf(-1), 1e-10));
      });

      test('pdf max at mean', () {
        final d = Normal(mu: 5, sigma: 2);
        expect(d.pdf(5), greaterThan(d.pdf(4)));
        expect(d.pdf(5), greaterThan(d.pdf(6)));
      });
    });

    group('logpdf', () {
      test('logpdf(x) == ln(pdf(x))', () {
        expect(std.logpdf(1.5), closeTo(math.log(std.pdf(1.5)), 1e-10));
      });
    });

    group('cdf', () {
      test('cdf(0) for standard normal = 0.5', () {
        expect(std.cdf(0), closeTo(0.5, 1e-7));
      });

      test('cdf(-inf) → 0', () {
        expect(std.cdf(-10), closeTo(0.0, 1e-7));
      });

      test('cdf(+inf) → 1', () {
        expect(std.cdf(10), closeTo(1.0, 1e-7));
      });

      test('cdf(1.96) ≈ 0.975', () {
        expect(std.cdf(1.96), closeTo(0.975, 1e-3));
      });

      test('cdf(-1.96) ≈ 0.025', () {
        expect(std.cdf(-1.96), closeTo(0.025, 1e-3));
      });
    });

    group('inverseCdf', () {
      test('inverseCdf(0.5) ≈ 0 for standard normal', () {
        expect(std.inverseCdf(0.5), closeTo(0.0, 1e-6));
      });

      test('inverseCdf(0.975) ≈ 1.96', () {
        expect(std.inverseCdf(0.975), closeTo(1.96, 1e-2));
      });

      test('inverseCdf(0.025) ≈ -1.96', () {
        expect(std.inverseCdf(0.025), closeTo(-1.96, 1e-2));
      });

      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(std.cdf(std.inverseCdf(p)), closeTo(p, 1e-4));
        }
      });

      test('p outside (0,1) throws', () {
        expect(() => std.inverseCdf(0), throwsA(isA<InvalidInputException>()));
        expect(() => std.inverseCdf(1), throwsA(isA<InvalidInputException>()));
      });
    });

    group('fit', () {
      test('fit recovers parameters', () {
        // Generate data with known parameters
        final rng = math.Random(42);
        final data = List.generate(1000, (_) => 5.0 + 2.0 * _boxMullerZ(rng));
        final fitted = Normal.fit(data);
        expect(fitted.mu, closeTo(5.0, 0.2));
        expect(fitted.sigma, closeTo(2.0, 0.2));
      });

      test('fit empty throws', () {
        expect(() => Normal.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit single element throws', () {
        expect(() => Normal.fit([1]), throwsA(isA<EmptyDataException>()));
      });
    });

    group('logLikelihood / AIC / BIC', () {
      test('logLikelihood is negative', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        expect(std.logLikelihood(data), isNegative);
      });

      test('AIC = -2*LL + 2*k', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final ll = std.logLikelihood(data);
        expect(std.aic(data), closeTo(-2 * ll + 2 * 2, 1e-10));
      });

      test('BIC = -2*LL + k*ln(n)', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final ll = std.logLikelihood(data);
        final expected = -2 * ll + 2 * math.log(5);
        expect(std.bic(data), closeTo(expected, 1e-10));
      });
    });
  });
}

/// Box-Muller transform to generate standard normal samples.
double _boxMullerZ(math.Random rng) {
  final u1 = rng.nextDouble();
  final u2 = rng.nextDouble();
  return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
}
