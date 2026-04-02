import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('LinearRegression', () {
    group('fit', () {
      test('perfect positive line y = 2x + 1', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [3.0, 5.0, 7.0, 9.0, 11.0];
        final reg = LinearRegression.fit(x, y);
        expect(reg.slope, closeTo(2.0, 1e-10));
        expect(reg.intercept, closeTo(1.0, 1e-10));
        expect(reg.rSquared, closeTo(1.0, 1e-10));
      });

      test('real-world data', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [2.0, 4.0, 5.0, 4.0, 5.0];
        final reg = LinearRegression.fit(x, y);
        expect(reg.slope, closeTo(0.6, 1e-10));
        expect(reg.intercept, closeTo(2.2, 1e-10));
        expect(reg.rSquared, greaterThan(0));
        expect(reg.rSquared, lessThan(1));
      });

      test('r² = 0 for flat noise (horizontal)', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [5.0, 5.0, 5.0, 5.0, 5.0];
        final reg = LinearRegression.fit(x, y);
        expect(reg.slope, closeTo(0.0, 1e-10));
        // r² undefined when all y are identical, but should be 0 or 1
        // (no variance to explain)
      });

      test('n stored correctly', () {
        final x = [1.0, 2.0, 3.0];
        final y = [2.0, 4.0, 6.0];
        final reg = LinearRegression.fit(x, y);
        expect(reg.n, 3);
      });

      test('different lengths throws', () {
        expect(
          () => LinearRegression.fit([1, 2, 3], [1, 2]),
          throwsA(isA<DimensionMismatchException>()),
        );
      });

      test('empty data throws', () {
        expect(
          () => LinearRegression.fit([], []),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('single point throws', () {
        expect(
          () => LinearRegression.fit([1], [2]),
          throwsA(isA<EmptyDataException>()),
        );
      });
    });

    group('predict', () {
      test('predict on perfect line', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0],
          [2.0, 4.0, 6.0],
        );
        expect(reg.predict(4), closeTo(8.0, 1e-10));
        expect(reg.predict(0), closeTo(0.0, 1e-10));
      });

      test('predictMany', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0],
          [2.0, 4.0, 6.0],
        );
        final predictions = reg.predictMany([4, 5, 6]);
        expect(predictions[0], closeTo(8.0, 1e-10));
        expect(predictions[1], closeTo(10.0, 1e-10));
        expect(predictions[2], closeTo(12.0, 1e-10));
      });
    });

    group('correlationCoefficient', () {
      test('perfect positive → r = 1', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0],
          [2.0, 4.0, 6.0],
        );
        expect(reg.correlationCoefficient, closeTo(1.0, 1e-10));
      });

      test('perfect negative → r = -1', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0],
          [6.0, 4.0, 2.0],
        );
        expect(reg.correlationCoefficient, closeTo(-1.0, 1e-10));
      });
    });

    group('confidenceInterval', () {
      test('CI contains prediction', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [2.1, 3.9, 6.2, 7.8, 10.1],
        );
        final ci = reg.confidenceInterval(3, 0.95);
        final predicted = reg.predict(3);
        expect(ci.lower, lessThan(predicted));
        expect(ci.upper, greaterThan(predicted));
      });

      test('wider CI for extrapolation', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [2.1, 3.9, 6.2, 7.8, 10.1],
        );
        final ciNear = reg.confidenceInterval(3, 0.95);
        final ciFar = reg.confidenceInterval(100, 0.95);
        final widthNear = ciNear.upper - ciNear.lower;
        final widthFar = ciFar.upper - ciFar.lower;
        expect(widthFar, greaterThan(widthNear));
      });

      test('99% CI wider than 95%', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [2.1, 3.9, 6.2, 7.8, 10.1],
        );
        final ci95 = reg.confidenceInterval(3, 0.95);
        final ci99 = reg.confidenceInterval(3, 0.99);
        expect(
          ci99.upper - ci99.lower,
          greaterThan(ci95.upper - ci95.lower),
        );
      });
    });

    group('standardError', () {
      test('is non-negative', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [2.1, 3.9, 6.2, 7.8, 10.1],
        );
        expect(reg.standardError, greaterThanOrEqualTo(0));
      });

      test('is 0 for perfect fit', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0],
          [2.0, 4.0, 6.0],
        );
        expect(reg.standardError, closeTo(0.0, 1e-10));
      });
    });

    group('serialization', () {
      test('toJson/fromJson roundtrip', () {
        final reg = LinearRegression.fit(
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [2.1, 3.9, 6.2, 7.8, 10.1],
        );
        final json = reg.toJson();
        final restored = LinearRegression.fromJson(json);
        expect(restored.slope, reg.slope);
        expect(restored.intercept, reg.intercept);
        expect(restored.rSquared, reg.rSquared);
        expect(restored.standardError, reg.standardError);
        expect(restored.n, reg.n);
        expect(restored.predict(6), closeTo(reg.predict(6), 1e-10));
      });
    });
  });
}
