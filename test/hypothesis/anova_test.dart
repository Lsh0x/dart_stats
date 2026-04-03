import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('oneWayAnova', () {
    group('basic tests', () {
      test('three groups with clear differences → small p-value', () {
        final g1 = [5, 7, 9, 8, 6];
        final g2 = [2, 4, 3, 5, 4];
        final g3 = [8, 9, 10, 7, 8];

        final r = oneWayAnova([g1, g2, g3]);

        expect(r.fStatistic, greaterThan(1.0));
        expect(r.pValue, lessThan(0.05));
        expect(r.dfBetween, 2);
        expect(r.dfWithin, 12);
      });

      test('three groups with equal means → large p-value', () {
        final g1 = [5, 7, 6, 5, 7];
        final g2 = [6, 5, 7, 6, 6];
        final g3 = [7, 5, 6, 7, 5];

        final r = oneWayAnova([g1, g2, g3]);

        expect(r.fStatistic, lessThan(1.0));
        expect(r.pValue, greaterThan(0.05));
      });
    });

    group('ANOVA table consistency', () {
      test('F = msBetween / msWithin', () {
        final g1 = [5, 7, 9, 8, 6];
        final g2 = [2, 4, 3, 5, 4];
        final g3 = [8, 9, 10, 7, 8];

        final r = oneWayAnova([g1, g2, g3]);

        expect(r.fStatistic, closeTo(r.msBetween / r.msWithin, 1e-10));
      });

      test('msBetween = ssBetween / dfBetween', () {
        final r = oneWayAnova([
          [1, 2, 3],
          [4, 5, 6],
        ]);
        expect(r.msBetween, closeTo(r.ssBetween / r.dfBetween, 1e-10));
      });

      test('msWithin = ssWithin / dfWithin', () {
        final r = oneWayAnova([
          [1, 2, 3],
          [4, 5, 6],
        ]);
        expect(r.msWithin, closeTo(r.ssWithin / r.dfWithin, 1e-10));
      });

      test('ss_between + ss_within ≈ ss_total', () {
        final groups = [
          [5, 7, 9, 8, 6],
          [2, 4, 3, 5, 4],
          [8, 9, 10, 7, 8],
        ];
        final r = oneWayAnova(groups);

        // Compute SSTotal manually
        final all = groups.expand((g) => g).map((x) => x.toDouble()).toList();
        final grandMean = all.fold(0.0, (a, b) => a + b) / all.length;
        final ssTotal = all.fold(
          0.0,
          (s, x) => s + (x - grandMean) * (x - grandMean),
        );

        expect(r.ssBetween + r.ssWithin, closeTo(ssTotal, 1e-10));
      });
    });

    group('different group sizes', () {
      test('unequal group sizes work', () {
        final r = oneWayAnova([
          [5, 7, 9, 8],
          [2, 4, 3],
          [8, 9, 10, 7, 8, 9],
        ]);

        expect(r.dfBetween, 2);
        expect(r.dfWithin, 10);
      });
    });

    group('p-value validation', () {
      test('p-value in [0, 1]', () {
        final r = oneWayAnova([
          [1.0, 2.0],
          [3.0, 4.0],
        ]);

        expect(r.pValue, greaterThanOrEqualTo(0));
        expect(r.pValue, lessThanOrEqualTo(1));
      });

      test('identical groups → F is NaN, p = 1', () {
        final r = oneWayAnova([
          [5, 5, 5],
          [5, 5, 5],
        ]);
        // msWithin = 0 → F = NaN
        expect(r.fStatistic.isNaN, isTrue);
        expect(r.pValue, 1.0);
      });
    });

    group('edge cases and errors', () {
      test('fewer than 2 groups throws', () {
        expect(
          () => oneWayAnova([
            [1, 2, 3],
          ]),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('empty groups throws', () {
        expect(
          () => oneWayAnova([
            [],
            [1, 2],
          ]),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('group with 1 observation throws', () {
        expect(
          () => oneWayAnova([
            [1],
            [2, 3],
          ]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('reference values', () {
      // Manual: SS_B=60.933, SS_W=20.4, MS_B=30.467, MS_W=1.7, F=17.922
      test('manual reference: 3 groups', () {
        final r = oneWayAnova([
          [5, 7, 9, 8, 6],
          [2, 4, 3, 5, 4],
          [8, 9, 10, 7, 8],
        ]);

        expect(r.fStatistic, closeTo(17.922, 0.01));
        expect(r.pValue, lessThan(0.001));
      });
    });

    test('toString', () {
      final r = oneWayAnova([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(r.toString(), contains('AnovaResult'));
    });
  });
}
