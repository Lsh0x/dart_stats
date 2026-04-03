import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('erf', () {
    test('erf(0) ≈ 0', () {
      expect(erf(0), closeTo(0.0, 1e-7));
    });

    test('erf(1) ≈ 0.84270', () {
      expect(erf(1), closeTo(0.84270079294971, 1.5e-7));
    });

    test('erf(-1) ≈ -0.84270 (odd function)', () {
      expect(erf(-1), closeTo(-0.84270079294971, 1.5e-7));
    });

    test('erf(2) ≈ 0.99532', () {
      expect(erf(2), closeTo(0.99532226501895, 1.5e-7));
    });

    test('erf(3) ≈ 0.99998', () {
      expect(erf(3), closeTo(0.99997790950300, 1e-5));
    });
  });

  group('erfc', () {
    test('erfc(0) ≈ 1', () {
      expect(erfc(0), closeTo(1.0, 1e-7));
    });

    test('erfc(x) == 1 - erf(x)', () {
      expect(erfc(1.5), closeTo(1.0 - erf(1.5), 1e-10));
    });
  });

  group('lnGamma', () {
    test('lnGamma(1) == 0 (0! = 1)', () {
      expect(lnGamma(1), closeTo(0.0, 1e-10));
    });

    test('lnGamma(2) == 0 (1! = 1)', () {
      expect(lnGamma(2), closeTo(0.0, 1e-10));
    });

    test('lnGamma(0.5) ≈ ln(sqrt(pi))', () {
      expect(lnGamma(0.5), closeTo(math.log(math.sqrt(math.pi)), 1e-10));
    });

    test('lnGamma(5) == ln(24)', () {
      expect(lnGamma(5), closeTo(math.log(24), 1e-10));
    });

    test('lnGamma(10) == ln(362880)', () {
      expect(lnGamma(10), closeTo(math.log(362880), 1e-8));
    });

    test('lnGamma(0) throws', () {
      expect(() => lnGamma(0), throwsA(isA<InvalidInputException>()));
    });

    test('lnGamma(-1) throws', () {
      expect(() => lnGamma(-1), throwsA(isA<InvalidInputException>()));
    });
  });

  group('gammaFn', () {
    test('gamma(1) == 1', () {
      expect(gammaFn(1), closeTo(1.0, 1e-10));
    });

    test('gamma(0.5) == sqrt(pi)', () {
      expect(gammaFn(0.5), closeTo(math.sqrt(math.pi), 1e-10));
    });

    test('gamma(5) == 24', () {
      expect(gammaFn(5), closeTo(24.0, 1e-8));
    });
  });

  group('regularizedIncompleteGamma', () {
    test('P(1, 0) == 0', () {
      expect(regularizedIncompleteGamma(1, 0), closeTo(0.0, 1e-10));
    });

    test('P(1, 1) ≈ 0.6321 (1 - e^-1)', () {
      expect(
        regularizedIncompleteGamma(1, 1),
        closeTo(1.0 - math.exp(-1), 1e-7),
      );
    });

    test('P(2, 1) ≈ 0.2642', () {
      expect(regularizedIncompleteGamma(2, 1), closeTo(0.26424111765712, 1e-6));
    });

    test('P(0.5, 1) ≈ 0.8427 (erf(1))', () {
      expect(
        regularizedIncompleteGamma(0.5, 1),
        closeTo(0.84270079294971, 1e-6),
      );
    });
  });

  group('betaFn', () {
    test('B(1, 1) == 1', () {
      expect(betaFn(1, 1), closeTo(1.0, 1e-10));
    });

    test('B(2, 3) == 1/12', () {
      expect(betaFn(2, 3), closeTo(1.0 / 12.0, 1e-10));
    });

    test('B(0.5, 0.5) == pi', () {
      expect(betaFn(0.5, 0.5), closeTo(math.pi, 1e-8));
    });
  });

  group('lnBeta', () {
    test('lnBeta(1, 1) == 0', () {
      expect(lnBeta(1, 1), closeTo(0.0, 1e-10));
    });

    test('lnBeta(2, 3) == ln(1/12)', () {
      expect(lnBeta(2, 3), closeTo(math.log(1.0 / 12.0), 1e-10));
    });
  });

  group('regularizedIncompleteBeta', () {
    test('I(0.5, 0.5, 0.5) == 0.5', () {
      expect(regularizedIncompleteBeta(0.5, 0.5, 0.5), closeTo(0.5, 1e-6));
    });

    test('I(1, 1, x) == x (uniform)', () {
      expect(regularizedIncompleteBeta(1, 1, 0.3), closeTo(0.3, 1e-6));
      expect(regularizedIncompleteBeta(1, 1, 0.7), closeTo(0.7, 1e-6));
    });

    test('I(a, b, 0) == 0', () {
      expect(regularizedIncompleteBeta(2, 3, 0), closeTo(0.0, 1e-10));
    });

    test('I(a, b, 1) == 1', () {
      expect(regularizedIncompleteBeta(2, 3, 1), closeTo(1.0, 1e-10));
    });

    test('I(2, 5, 0.4) known value', () {
      // Precomputed: ≈ 0.76672
      expect(regularizedIncompleteBeta(2, 5, 0.4), closeTo(0.76672, 1e-4));
    });
  });

  group('bisectInverseCdf', () {
    // Use standard normal CDF as test case
    double normalCdf(double x) => 0.5 * (1.0 + erf(x / math.sqrt(2)));

    test('inverse of CDF(0) = 0.5 → x ≈ 0', () {
      final x = bisectInverseCdf(normalCdf, 0.5, lo: -10, hi: 10);
      expect(x, closeTo(0.0, 1e-6));
    });

    test('inverse of CDF(0.975) ≈ 1.96', () {
      final x = bisectInverseCdf(normalCdf, 0.975, lo: -10, hi: 10);
      expect(x, closeTo(1.9599639845, 1e-4));
    });

    test('inverse of CDF(0.025) ≈ -1.96', () {
      final x = bisectInverseCdf(normalCdf, 0.025, lo: -10, hi: 10);
      expect(x, closeTo(-1.9599639845, 1e-4));
    });

    test('p outside (0,1) throws', () {
      expect(
        () => bisectInverseCdf(normalCdf, 0, lo: -10, hi: 10),
        throwsA(isA<InvalidInputException>()),
      );
      expect(
        () => bisectInverseCdf(normalCdf, 1, lo: -10, hi: 10),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
