import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('NegativeBinomial distribution', () {
    late NegativeBinomial d;

    setUp(() {
      // r=5 successes, p=0.5
      d = NegativeBinomial(r: 5, p: 0.5);
    });

    group('construction', () {
      test('valid parameters', () {
        expect(d.r, 5);
        expect(d.p, 0.5);
      });

      test('r <= 0 throws', () {
        expect(
          () => NegativeBinomial(r: 0, p: 0.5),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => NegativeBinomial(r: -1, p: 0.5),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('p <= 0 throws', () {
        expect(
          () => NegativeBinomial(r: 5, p: 0),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('p > 1 throws', () {
        expect(
          () => NegativeBinomial(r: 5, p: 1.1),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('p = 1 is valid (always succeed, no failures)', () {
        final nb = NegativeBinomial(r: 3, p: 1.0);
        expect(nb.distMean, closeTo(0.0, 1e-10));
      });
    });

    group('properties', () {
      test('mean = r*(1-p)/p', () {
        // r=5, p=0.5 → mean = 5*0.5/0.5 = 5
        expect(d.distMean, closeTo(5.0, 1e-10));
      });

      test('variance = r*(1-p)/p^2', () {
        // r=5, p=0.5 → var = 5*0.5/0.25 = 10
        expect(d.distVariance, closeTo(10.0, 1e-10));
      });

      test('name', () {
        expect(d.name, 'NegativeBinomial');
      });

      test('numParams', () {
        expect(d.numParams, 2);
      });

      test('toString', () {
        expect(d.toString(), 'NegativeBinomial(r=5, p=0.5)');
      });
    });

    group('pmf', () {
      // NB(r=5, p=0.5): P(k) = C(k+4, k) * 0.5^5 * 0.5^k
      test('pmf(0) = p^r = 0.5^5 = 0.03125', () {
        expect(d.pmf(0), closeTo(0.03125, 1e-8));
      });

      test('pmf(5) ≈ 0.123047', () {
        // C(9,5) * 0.5^10 = 126 * 0.0009765625 ≈ 0.123047
        expect(d.pmf(5), closeTo(0.123047, 1e-4));
      });

      test('pmf(-1) = 0', () {
        expect(d.pmf(-1), 0.0);
      });

      test('NB(r=1, p=0.5) matches Geometric(p=0.5)', () {
        final nb1 = NegativeBinomial(r: 1, p: 0.5);
        final geo = Geometric(p: 0.5);
        for (var k = 0; k <= 10; k++) {
          expect(nb1.pmf(k), closeTo(geo.pmf(k), 1e-10));
        }
      });

      test('sum of pmf over large range ≈ 1', () {
        var total = 0.0;
        for (var k = 0; k <= 60; k++) {
          total += d.pmf(k);
        }
        expect(total, closeTo(1.0, 1e-6));
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
      test('cdf(-1) = 0', () {
        expect(d.cdf(-1), 0.0);
      });

      test('cdf(0) = pmf(0)', () {
        expect(d.cdf(0), closeTo(d.pmf(0), 1e-10));
      });

      // scipy.stats.nbinom.cdf(5, 5, 0.5) ≈ 0.6230
      test('cdf(5) ≈ 0.623', () {
        expect(d.cdf(5), closeTo(0.623, 1e-2));
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
      test('fit returns valid distribution', () {
        // data with mean ≈ 5 and variance > mean
        final data = [3, 5, 7, 4, 8, 2, 6, 5, 9, 1];
        final fitted = NegativeBinomial.fit(data);
        expect(fitted.r, greaterThan(0));
        expect(fitted.p, greaterThan(0));
        expect(fitted.p, lessThanOrEqualTo(1));
      });

      test('fit with variance <= mean uses fallback', () {
        // all same → variance = 0 < mean
        final data = [3, 3, 3, 3, 3];
        final fitted = NegativeBinomial.fit(data);
        expect(fitted.r, 1);
      });

      test('fit empty data throws', () {
        expect(
          () => NegativeBinomial.fit([]),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('fit negative values throws', () {
        expect(
          () => NegativeBinomial.fit([1, -1]),
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
