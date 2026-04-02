import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('LogNormal distribution', () {
    late LogNormal d;

    setUp(() {
      d = LogNormal(mu: 0, sigma: 1);
    });

    group('construction', () {
      test('default parameters', () {
        expect(d.mu, 0);
        expect(d.sigma, 1);
      });

      test('sigma <= 0 throws', () {
        expect(
          () => LogNormal(mu: 0, sigma: 0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('mean = exp(mu + sigma^2/2)', () {
        final ln = LogNormal(mu: 1, sigma: 0.5);
        final expected = math.exp(1 + 0.25 / 2);
        expect(ln.distMean, closeTo(expected, 1e-10));
      });

      test('variance', () {
        final ln = LogNormal(mu: 1, sigma: 0.5);
        final expected = (math.exp(0.25) - 1) * math.exp(2 * 1 + 0.25);
        expect(ln.distVariance, closeTo(expected, 1e-8));
      });

      test('name is LogNormal', () {
        expect(d.name, 'LogNormal');
      });
    });

    group('pdf', () {
      test('pdf(0) = 0', () {
        expect(d.pdf(0), 0.0);
      });

      test('pdf negative = 0', () {
        expect(d.pdf(-1), 0.0);
      });

      test('pdf(1) for mu=0,sigma=1 ≈ 0.3989', () {
        // At x=1, ln(1)=0, so pdf = (1/1*sqrt(2pi)) * exp(0) = invSqrt2Pi
        expect(d.pdf(1), closeTo(invSqrt2Pi, 1e-7));
      });
    });

    group('cdf', () {
      test('cdf(0) = 0', () {
        expect(d.cdf(0), 0.0);
      });

      test('cdf negative = 0', () {
        expect(d.cdf(-1), 0.0);
      });

      test('cdf(1) for mu=0,sigma=1 = 0.5', () {
        // ln(1) = 0, so CDF = Phi(0) = 0.5
        expect(d.cdf(1), closeTo(0.5, 1e-7));
      });

      test('cdf increases monotonically', () {
        expect(d.cdf(0.5), lessThan(d.cdf(1)));
        expect(d.cdf(1), lessThan(d.cdf(2)));
      });
    });

    group('inverseCdf', () {
      test('inverseCdf(0.5) for mu=0,sigma=1 = 1.0', () {
        expect(d.inverseCdf(0.5), closeTo(1.0, 1e-4));
      });

      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(d.cdf(d.inverseCdf(p)), closeTo(p, 1e-3));
        }
      });
    });

    group('fit', () {
      test('fit recovers parameters from lognormal data', () {
        final rng = math.Random(42);
        // Generate lognormal: exp(mu + sigma * Z)
        final data = List.generate(
          1000,
          (_) => math.exp(1.0 + 0.5 * _boxMullerZ(rng)),
        );
        final fitted = LogNormal.fit(data);
        expect(fitted.mu, closeTo(1.0, 0.1));
        expect(fitted.sigma, closeTo(0.5, 0.1));
      });

      test('fit with negative values throws', () {
        expect(
          () => LogNormal.fit([1, 2, -1, 3]),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('fit empty throws', () {
        expect(
          () => LogNormal.fit([]),
          throwsA(isA<EmptyDataException>()),
        );
      });
    });

    group('AIC/BIC', () {
      test('AIC uses 2 params', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0];
        final ll = d.logLikelihood(data);
        expect(d.aic(data), closeTo(-2 * ll + 4, 1e-10));
      });
    });
  });
}

double _boxMullerZ(math.Random rng) {
  final u1 = rng.nextDouble();
  final u2 = rng.nextDouble();
  return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
}
