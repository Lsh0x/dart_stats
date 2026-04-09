import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  // ── KL divergence ──

  group('klDivergence', () {
    test('identical distributions → 0', () {
      expect(klDivergence([0.5, 0.5], [0.5, 0.5]), closeTo(0.0, 1e-10));
    });

    test('known value', () {
      // DKL([0.5, 0.5] || [0.25, 0.75])
      // = 0.5 * ln(0.5/0.25) + 0.5 * ln(0.5/0.75)
      // = 0.5 * ln(2) + 0.5 * ln(2/3)
      // ≈ 0.5 * 0.6931 + 0.5 * (-0.4055) ≈ 0.1438
      expect(
        klDivergence([0.5, 0.5], [0.25, 0.75]),
        closeTo(0.1438, 0.001),
      );
    });

    test('not symmetric', () {
      final pq = klDivergence([0.9, 0.1], [0.5, 0.5]);
      final qp = klDivergence([0.5, 0.5], [0.9, 0.1]);
      expect(pq, isNot(closeTo(qp, 1e-5)));
    });

    test('q=0 where p>0 → infinity', () {
      expect(klDivergence([0.5, 0.5], [1.0, 0.0]), double.infinity);
    });

    test('p=0 entries are skipped', () {
      // [0, 1] vs [0.5, 0.5] → only second term: 1*ln(1/0.5) = ln(2)
      expect(
        klDivergence([0.0, 1.0], [0.5, 0.5]),
        closeTo(math.ln2, 1e-10),
      );
    });

    test('dimension mismatch throws', () {
      expect(
        () => klDivergence([0.5, 0.5], [0.33, 0.33, 0.34]),
        throwsA(isA<DimensionMismatchException>()),
      );
    });

    test('negative probability throws', () {
      expect(
        () => klDivergence([-0.1, 1.1], [0.5, 0.5]),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('empty distributions throw', () {
      expect(
        () => klDivergence([], []),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });

  // ── JS divergence ──

  group('jsDivergence', () {
    test('identical distributions → 0', () {
      expect(jsDivergence([0.5, 0.5], [0.5, 0.5]), closeTo(0.0, 1e-10));
    });

    test('is symmetric', () {
      final pq = jsDivergence([0.9, 0.1], [0.5, 0.5]);
      final qp = jsDivergence([0.5, 0.5], [0.9, 0.1]);
      expect(pq, closeTo(qp, 1e-10));
    });

    test('bounded by ln(2)', () {
      // Maximally different: [1,0] vs [0,1]
      final jsd = jsDivergence([1.0, 0.0], [0.0, 1.0]);
      expect(jsd, closeTo(math.ln2, 1e-10));
    });

    test('always non-negative', () {
      expect(jsDivergence([0.3, 0.7], [0.8, 0.2]), greaterThanOrEqualTo(0));
    });

    test('handles zeros gracefully', () {
      // No infinity: M = midpoint always > 0 when P+Q > 0
      expect(
        jsDivergence([1.0, 0.0], [0.5, 0.5]),
        greaterThan(0),
      );
    });
  });

  group('jsDistance', () {
    test('identical → 0', () {
      expect(jsDistance([0.5, 0.5], [0.5, 0.5]), closeTo(0.0, 1e-10));
    });

    test('bounded by sqrt(ln(2))', () {
      final d = jsDistance([1.0, 0.0], [0.0, 1.0]);
      expect(d, closeTo(math.sqrt(math.ln2), 1e-10));
    });
  });

  // ── Hellinger distance ──

  group('hellingerDistance', () {
    test('identical distributions → 0', () {
      expect(
        hellingerDistance([0.5, 0.5], [0.5, 0.5]),
        closeTo(0.0, 1e-10),
      );
    });

    test('maximally different → 1', () {
      expect(
        hellingerDistance([1.0, 0.0], [0.0, 1.0]),
        closeTo(1.0, 1e-10),
      );
    });

    test('is symmetric', () {
      final pq = hellingerDistance([0.9, 0.1], [0.5, 0.5]);
      final qp = hellingerDistance([0.5, 0.5], [0.9, 0.1]);
      expect(pq, closeTo(qp, 1e-10));
    });

    test('bounded in [0, 1]', () {
      final h = hellingerDistance([0.3, 0.7], [0.8, 0.2]);
      expect(h, greaterThanOrEqualTo(0));
      expect(h, lessThanOrEqualTo(1));
    });

    test('known value', () {
      // H([0.5,0.5], [0.25,0.75])
      // = (1/√2) × √( (√0.5−√0.25)² + (√0.5−√0.75)² )
      final p = [0.5, 0.5];
      final q = [0.25, 0.75];
      final h = hellingerDistance(p, q);
      final expected = (1 / math.sqrt(2)) *
          math.sqrt(
            math.pow(math.sqrt(0.5) - math.sqrt(0.25), 2) +
                math.pow(math.sqrt(0.5) - math.sqrt(0.75), 2),
          );
      expect(h, closeTo(expected, 1e-10));
    });
  });

  // ── Bhattacharyya coefficient ──

  group('bhattacharyyaCoefficient', () {
    test('identical distributions → 1', () {
      expect(
        bhattacharyyaCoefficient([0.5, 0.5], [0.5, 0.5]),
        closeTo(1.0, 1e-10),
      );
    });

    test('completely disjoint → 0', () {
      expect(
        bhattacharyyaCoefficient([1.0, 0.0], [0.0, 1.0]),
        closeTo(0.0, 1e-10),
      );
    });

    test('H² = 1 − BC relationship', () {
      final p = [0.3, 0.7];
      final q = [0.8, 0.2];
      final h = hellingerDistance(p, q);
      final bc = bhattacharyyaCoefficient(p, q);
      expect(h * h, closeTo(1 - bc, 1e-10));
    });
  });

  // ── Total variation distance ──

  group('totalVariationDistance', () {
    test('identical → 0', () {
      expect(
        totalVariationDistance([0.5, 0.5], [0.5, 0.5]),
        closeTo(0.0, 1e-10),
      );
    });

    test('maximally different → 1', () {
      expect(
        totalVariationDistance([1.0, 0.0], [0.0, 1.0]),
        closeTo(1.0, 1e-10),
      );
    });

    test('is symmetric', () {
      final pq = totalVariationDistance([0.9, 0.1], [0.5, 0.5]);
      final qp = totalVariationDistance([0.5, 0.5], [0.9, 0.1]);
      expect(pq, closeTo(qp, 1e-10));
    });

    test('known value', () {
      // TV([0.5,0.5], [0.25,0.75]) = ½(|0.25| + |0.25|) = 0.25
      expect(
        totalVariationDistance([0.5, 0.5], [0.25, 0.75]),
        closeTo(0.25, 1e-10),
      );
    });
  });
}
