import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Poisson distribution', () {
    late Poisson d;

    setUp(() {
      d = Poisson(lambda: 3.0);
    });

    group('construction', () {
      test('valid parameter', () {
        expect(d.lambda, 3.0);
      });

      test('lambda <= 0 throws', () {
        expect(() => Poisson(lambda: 0), throwsA(isA<InvalidInputException>()));
        expect(
          () => Poisson(lambda: -1),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('mean = lambda', () {
        expect(d.distMean, closeTo(3.0, 1e-10));
      });

      test('variance = lambda', () {
        expect(d.distVariance, closeTo(3.0, 1e-10));
      });

      test('name', () {
        expect(d.name, 'Poisson');
      });

      test('numParams', () {
        expect(d.numParams, 1);
      });

      test('toString', () {
        expect(d.toString(), 'Poisson(lambda=3.0)');
      });
    });

    group('pmf', () {
      // Reference: scipy.stats.poisson.pmf(k, mu=3)
      test('pmf(0) = e^-3 ≈ 0.049787', () {
        expect(d.pmf(0), closeTo(math.exp(-3), 1e-8));
      });

      test('pmf(3) ≈ 0.224042', () {
        expect(d.pmf(3), closeTo(0.224042, 1e-5));
      });

      test('pmf(5) ≈ 0.100819', () {
        expect(d.pmf(5), closeTo(0.100819, 1e-5));
      });

      test('pmf(-1) = 0', () {
        expect(d.pmf(-1), 0.0);
      });

      test('sum of pmf over large range ≈ 1', () {
        var total = 0.0;
        for (var k = 0; k <= 30; k++) {
          total += d.pmf(k);
        }
        expect(total, closeTo(1.0, 1e-10));
      });

      test('Poisson(10) pmf(10) ≈ 0.12511', () {
        final p10 = Poisson(lambda: 10.0);
        expect(p10.pmf(10), closeTo(0.12511, 1e-4));
      });
    });

    group('logpmf', () {
      test('logpmf(3) = ln(pmf(3))', () {
        expect(d.logpmf(3), closeTo(math.log(d.pmf(3)), 1e-10));
      });

      test('logpmf(-1) = -infinity', () {
        expect(d.logpmf(-1), double.negativeInfinity);
      });
    });

    group('cdf', () {
      // scipy.stats.poisson.cdf(3, mu=3) ≈ 0.647232
      test('cdf(3) ≈ 0.647232', () {
        expect(d.cdf(3), closeTo(0.647232, 1e-5));
      });

      test('cdf(-1) = 0', () {
        expect(d.cdf(-1), 0.0);
      });

      test('cdf(100) ≈ 1', () {
        expect(d.cdf(100), closeTo(1.0, 1e-10));
      });

      test('cdf is monotonically non-decreasing', () {
        var prev = 0.0;
        for (var k = 0; k <= 20; k++) {
          final c = d.cdf(k);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });
    });

    group('inverseCdf', () {
      test('inverseCdf(0) = 0', () {
        expect(d.inverseCdf(0), 0);
      });

      test('inverseCdf round-trip', () {
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          final k = d.inverseCdf(p);
          expect(d.cdf(k), greaterThanOrEqualTo(p));
          if (k > 0) {
            expect(d.cdf(k - 1), lessThan(p));
          }
        }
      });
    });

    group('fit', () {
      test('fit recovers lambda', () {
        final data = [2, 3, 4, 3, 2, 5, 1, 3, 4, 3];
        final fitted = Poisson.fit(data);
        expect(fitted.lambda, closeTo(3.0, 0.1));
      });

      test('fit empty data throws', () {
        expect(() => Poisson.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit negative values throws', () {
        expect(
          () => Poisson.fit([1, -1, 2]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('logLikelihood / AIC / BIC', () {
      test('logLikelihood is negative', () {
        final data = [2, 3, 4, 3, 2];
        expect(d.logLikelihood(data), isNegative);
      });

      test('AIC and BIC are finite', () {
        final data = [2, 3, 4, 3, 2];
        expect(d.aic(data).isFinite, isTrue);
        expect(d.bic(data).isFinite, isTrue);
      });
    });
  });
}
