import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('chiSquareGoodnessOfFit', () {
    group('basic tests', () {
      test('fair die — statistic = 2.5, df = 5', () {
        final observed = [24, 20, 18, 22, 15, 21];
        final expected = [20.0, 20.0, 20.0, 20.0, 20.0, 20.0];

        final r = chiSquareGoodnessOfFit(observed, expected);

        expect(r.statistic, closeTo(2.5, 1e-10));
        expect(r.degreesOfFreedom, 5);
        expect(r.pValue, greaterThan(0.05));
      });

      test('biased die — small p-value', () {
        final observed = [5, 8, 9, 8, 10, 60]; // obviously biased
        final expected = [16.67, 16.67, 16.67, 16.67, 16.67, 16.67];

        final r = chiSquareGoodnessOfFit(observed, expected);

        expect(r.statistic, greaterThan(10));
        expect(r.pValue, lessThan(0.05));
      });

      test('perfect fit → statistic = 0', () {
        final observed = [20, 30, 50];
        final expected = [20.0, 30.0, 50.0];

        final r = chiSquareGoodnessOfFit(observed, expected);

        expect(r.statistic, closeTo(0.0, 1e-10));
      });
    });

    group('p-value', () {
      test('p-value in [0, 1]', () {
        final r = chiSquareGoodnessOfFit([10, 15, 25], [16.67, 16.67, 16.67]);
        expect(r.pValue, greaterThanOrEqualTo(0));
        expect(r.pValue, lessThanOrEqualTo(1));
      });
    });

    group('edge cases', () {
      test('single category → df = 0, p = 0', () {
        final r = chiSquareGoodnessOfFit([10], [10.0]);
        expect(r.degreesOfFreedom, 0);
        expect(r.statistic, closeTo(0.0, 1e-10));
      });
    });

    group('errors', () {
      test('empty observed throws', () {
        expect(
          () => chiSquareGoodnessOfFit([], [1.0]),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('empty expected throws', () {
        expect(
          () => chiSquareGoodnessOfFit([1], []),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('different lengths throws', () {
        expect(
          () => chiSquareGoodnessOfFit([1, 2], [1.0, 2.0, 3.0]),
          throwsA(isA<DimensionMismatchException>()),
        );
      });

      test('zero expected throws', () {
        expect(
          () => chiSquareGoodnessOfFit([10, 15], [15.0, 0.0]),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('negative expected throws', () {
        expect(
          () => chiSquareGoodnessOfFit([10, 15], [15.0, -5.0]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    test('toString', () {
      final r = chiSquareGoodnessOfFit([10, 20], [15.0, 15.0]);
      expect(r.toString(), contains('ChiSquareResult'));
    });
  });

  group('chiSquareIndependence', () {
    group('basic tests', () {
      test('2x2 contingency table', () {
        // Gender vs product preference
        final matrix = [
          [45, 55],
          [60, 40],
        ];

        final r = chiSquareIndependence(matrix);

        expect(r.degreesOfFreedom, 1);
        expect(r.statistic, closeTo(4.511, 0.01));
        expect(r.pValue, lessThan(0.05));
      });

      test('3x3 contingency table', () {
        final matrix = [
          [30, 25, 15],
          [35, 40, 30],
          [20, 30, 25],
        ];

        final r = chiSquareIndependence(matrix);

        expect(r.degreesOfFreedom, 4);
        expect(r.statistic, greaterThan(0));
      });

      test('independent variables → large p-value', () {
        // Rows proportional → independent
        final matrix = [
          [100, 200],
          [50, 100],
        ];

        final r = chiSquareIndependence(matrix);

        expect(r.statistic, closeTo(0.0, 0.1));
        expect(r.pValue, greaterThan(0.05));
      });
    });

    group('smoking / lung cancer reference', () {
      // Classic example
      test('strong association → small p-value', () {
        final matrix = [
          [158, 122],
          [40, 180],
        ];

        final r = chiSquareIndependence(matrix);

        expect(r.degreesOfFreedom, 1);
        expect(r.pValue, lessThan(0.001));
      });
    });

    group('errors', () {
      test('empty matrix throws', () {
        expect(
          () => chiSquareIndependence([]),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('unequal row lengths throws', () {
        expect(
          () => chiSquareIndependence([
            [10, 15],
            [20, 25, 30],
          ]),
          throwsA(isA<DimensionMismatchException>()),
        );
      });
    });

    test('toString', () {
      final r = chiSquareIndependence([
        [10, 20],
        [30, 40],
      ]);
      expect(r.toString(), contains('ChiSquareResult'));
    });
  });
}
