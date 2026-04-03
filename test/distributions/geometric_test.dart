import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Geometric distribution', () {
    late Geometric d;

    setUp(() {
      d = Geometric(p: 0.5);
    });

    group('construction', () {
      test('valid parameter', () {
        expect(d.p, 0.5);
      });

      test('p <= 0 throws', () {
        expect(() => Geometric(p: 0), throwsA(isA<InvalidInputException>()));
        expect(() => Geometric(p: -0.1), throwsA(isA<InvalidInputException>()));
      });

      test('p > 1 throws', () {
        expect(() => Geometric(p: 1.1), throwsA(isA<InvalidInputException>()));
      });

      test('p = 1 is valid (always succeed on first try)', () {
        final g = Geometric(p: 1.0);
        expect(g.p, 1.0);
        expect(g.distMean, closeTo(0.0, 1e-10));
      });
    });

    group('properties', () {
      test('mean = (1-p)/p', () {
        expect(d.distMean, closeTo(1.0, 1e-10));
        expect(Geometric(p: 0.25).distMean, closeTo(3.0, 1e-10));
      });

      test('variance = (1-p)/p^2', () {
        expect(d.distVariance, closeTo(2.0, 1e-10));
        expect(Geometric(p: 0.25).distVariance, closeTo(12.0, 1e-10));
      });

      test('name', () {
        expect(d.name, 'Geometric');
      });

      test('numParams', () {
        expect(d.numParams, 1);
      });

      test('toString', () {
        expect(d.toString(), 'Geometric(p=0.5)');
      });
    });

    group('pmf', () {
      // Geometric(0.5): P(k) = 0.5^(k+1)
      test('pmf(0) = 0.5', () {
        expect(d.pmf(0), closeTo(0.5, 1e-10));
      });

      test('pmf(1) = 0.25', () {
        expect(d.pmf(1), closeTo(0.25, 1e-10));
      });

      test('pmf(2) = 0.125', () {
        expect(d.pmf(2), closeTo(0.125, 1e-10));
      });

      test('pmf(-1) = 0', () {
        expect(d.pmf(-1), 0.0);
      });

      test('Geometric(0.3) pmf(4) ≈ 0.3 * 0.7^4', () {
        final g = Geometric(p: 0.3);
        expect(g.pmf(4), closeTo(0.3 * math.pow(0.7, 4), 1e-10));
      });

      test('sum of pmf over large range ≈ 1', () {
        var total = 0.0;
        for (var k = 0; k <= 40; k++) {
          total += d.pmf(k);
        }
        expect(total, closeTo(1.0, 1e-10));
      });
    });

    group('logpmf', () {
      test('logpmf(1) = ln(pmf(1))', () {
        expect(d.logpmf(1), closeTo(math.log(d.pmf(1)), 1e-10));
      });

      test('logpmf(-1) = -infinity', () {
        expect(d.logpmf(-1), double.negativeInfinity);
      });
    });

    group('cdf', () {
      // CDF(k) = 1 - (1-p)^(k+1)
      test('cdf(0) = 0.5', () {
        expect(d.cdf(0), closeTo(0.5, 1e-10));
      });

      test('cdf(1) = 0.75', () {
        expect(d.cdf(1), closeTo(0.75, 1e-10));
      });

      test('cdf(2) = 0.875', () {
        expect(d.cdf(2), closeTo(0.875, 1e-10));
      });

      test('cdf(-1) = 0', () {
        expect(d.cdf(-1), 0.0);
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

      test('inverseCdf(0.5) = 0 for p=0.5', () {
        // CDF(0) = 0.5 >= 0.5, so inverseCdf(0.5) = 0
        expect(d.inverseCdf(0.5), 0);
      });
    });

    group('fit', () {
      test('fit recovers p', () {
        // mean ≈ 1 → p ≈ 0.5
        final data = [0, 1, 2, 0, 1, 1, 0, 2, 1, 2];
        final fitted = Geometric.fit(data);
        expect(fitted.p, closeTo(0.5, 0.1));
      });

      test('fit empty data throws', () {
        expect(() => Geometric.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit negative values throws', () {
        expect(
          () => Geometric.fit([1, -1]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('logLikelihood / AIC / BIC', () {
      test('logLikelihood is negative', () {
        final data = [0, 1, 2, 1, 0];
        expect(d.logLikelihood(data), isNegative);
      });

      test('AIC and BIC are finite', () {
        final data = [0, 1, 2, 1, 0];
        expect(d.aic(data).isFinite, isTrue);
        expect(d.bic(data).isFinite, isTrue);
      });
    });
  });
}
