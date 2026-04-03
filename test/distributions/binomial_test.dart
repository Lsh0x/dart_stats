import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Binomial distribution', () {
    late Binomial d;

    setUp(() {
      d = Binomial(n: 10, p: 0.5);
    });

    group('construction', () {
      test('valid parameters', () {
        expect(d.n, 10);
        expect(d.p, 0.5);
      });

      test('n < 0 throws', () {
        expect(
          () => Binomial(n: -1, p: 0.5),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('p < 0 throws', () {
        expect(
          () => Binomial(n: 10, p: -0.1),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('p > 1 throws', () {
        expect(
          () => Binomial(n: 10, p: 1.1),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('edge case p=0', () {
        final b = Binomial(n: 5, p: 0.0);
        expect(b.p, 0.0);
      });

      test('edge case p=1', () {
        final b = Binomial(n: 5, p: 1.0);
        expect(b.p, 1.0);
      });
    });

    group('properties', () {
      test('mean = n*p', () {
        expect(d.distMean, closeTo(5.0, 1e-10));
        expect(Binomial(n: 20, p: 0.3).distMean, closeTo(6.0, 1e-10));
      });

      test('variance = n*p*(1-p)', () {
        expect(d.distVariance, closeTo(2.5, 1e-10));
        expect(Binomial(n: 20, p: 0.3).distVariance, closeTo(4.2, 1e-10));
      });

      test('name', () {
        expect(d.name, 'Binomial');
      });

      test('numParams', () {
        expect(d.numParams, 1);
      });

      test('toString', () {
        expect(d.toString(), 'Binomial(n=10, p=0.5)');
      });
    });

    group('pmf', () {
      // Reference: scipy.stats.binom.pmf
      test('Binom(10, 0.5) pmf(5) ≈ 0.24609375', () {
        expect(d.pmf(5), closeTo(0.24609375, 1e-8));
      });

      test('Binom(10, 0.5) pmf(0) ≈ 0.0009765625', () {
        expect(d.pmf(0), closeTo(0.0009765625, 1e-10));
      });

      test('Binom(10, 0.5) pmf(10) ≈ 0.0009765625', () {
        expect(d.pmf(10), closeTo(0.0009765625, 1e-10));
      });

      test('pmf(-1) = 0', () {
        expect(d.pmf(-1), 0.0);
      });

      test('pmf(11) = 0 (k > n)', () {
        expect(d.pmf(11), 0.0);
      });

      test('Binom(20, 0.3) pmf(6) ≈ 0.19163', () {
        final b = Binomial(n: 20, p: 0.3);
        expect(b.pmf(6), closeTo(0.19163, 1e-4));
      });

      test('sum of pmf over [0,n] ≈ 1', () {
        var total = 0.0;
        for (var k = 0; k <= 10; k++) {
          total += d.pmf(k);
        }
        expect(total, closeTo(1.0, 1e-10));
      });
    });

    group('logpmf', () {
      test('logpmf(5) = ln(pmf(5))', () {
        expect(d.logpmf(5), closeTo(math.log(d.pmf(5)), 1e-10));
      });

      test('logpmf(-1) = -infinity', () {
        expect(d.logpmf(-1), double.negativeInfinity);
      });
    });

    group('cdf', () {
      test('Binom(10, 0.5) cdf(5) ≈ 0.623046875', () {
        expect(d.cdf(5), closeTo(0.623046875, 1e-8));
      });

      test('cdf(-1) = 0', () {
        expect(d.cdf(-1), 0.0);
      });

      test('cdf(10) = 1', () {
        expect(d.cdf(10), closeTo(1.0, 1e-10));
      });

      test('cdf is monotonically non-decreasing', () {
        var prev = 0.0;
        for (var k = 0; k <= 10; k++) {
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

      test('inverseCdf(1) = n', () {
        expect(d.inverseCdf(1), 10);
      });

      test('inverseCdf(0.5) = 5', () {
        // median of Binom(10, 0.5) = 5
        expect(d.inverseCdf(0.5), 5);
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
      test('fit recovers p from fair coin flips', () {
        // 10 trials, each value in [0, 10]
        final data = [5, 4, 6, 5, 5, 3, 7, 5, 6, 4];
        final fitted = Binomial.fit(data, n: 10);
        expect(fitted.n, 10);
        expect(fitted.p, closeTo(0.5, 0.1));
      });

      test('fit empty data throws', () {
        expect(
          () => Binomial.fit([], n: 10),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('fit n <= 0 throws', () {
        expect(
          () => Binomial.fit([1, 2], n: 0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('logLikelihood / AIC / BIC', () {
      test('logLikelihood is negative', () {
        final data = [3, 5, 7, 4, 6];
        expect(d.logLikelihood(data), isNegative);
      });

      test('AIC and BIC are finite', () {
        final data = [3, 5, 7, 4, 6];
        expect(d.aic(data).isFinite, isTrue);
        expect(d.bic(data).isFinite, isTrue);
      });
    });
  });
}
