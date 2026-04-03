import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('MultipleLinearRegression', () {
    group('2D: y = 2*x1 + 3*x2 + 1', () {
      late MultipleLinearRegression model;
      late List<List<num>> x;
      late List<num> y;

      setUp(() {
        // Perfect linear relationship
        x = [
          [1, 1],
          [2, 2],
          [3, 3],
          [4, 4],
          [5, 5],
          [1, 5],
          [5, 1],
          [3, 1],
          [1, 3],
          [2, 4],
        ];
        y = x.map((row) => 2.0 * row[0] + 3.0 * row[1] + 1.0).toList();
        model = MultipleLinearRegression.fit(x, y);
      });

      test('coefficients recovered', () {
        expect(model.coefficients[0], closeTo(2.0, 1e-8));
        expect(model.coefficients[1], closeTo(3.0, 1e-8));
      });

      test('intercept recovered', () {
        expect(model.intercept, closeTo(1.0, 1e-8));
      });

      test('R² ≈ 1 for perfect fit', () {
        expect(model.rSquared, closeTo(1.0, 1e-8));
      });

      test('adjusted R² ≈ 1 for perfect fit', () {
        expect(model.adjustedRSquared, closeTo(1.0, 1e-6));
      });

      test('predict', () {
        expect(model.predict([10, 20]), closeTo(2 * 10 + 3 * 20 + 1, 1e-8));
      });

      test('predictMany', () {
        final predictions = model.predictMany([
          [1, 1],
          [2, 3],
        ]);
        expect(predictions[0], closeTo(6.0, 1e-8));
        expect(predictions[1], closeTo(14.0, 1e-8));
      });

      test('residuals ≈ 0 for perfect fit', () {
        for (final r in model.residuals) {
          expect(r, closeTo(0.0, 1e-8));
        }
      });

      test('n and p', () {
        expect(model.n, 10);
        expect(model.p, 2);
      });
    });

    group('3D: y = x1 - 2*x2 + 0.5*x3 + 10', () {
      late MultipleLinearRegression model;

      setUp(() {
        final x = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
          [2, 1, 4],
          [5, 3, 7],
          [3, 6, 2],
          [6, 4, 8],
          [8, 2, 5],
          [9, 7, 1],
          [4, 9, 3],
        ];
        final y = x
            .map((r) => 1.0 * r[0] - 2.0 * r[1] + 0.5 * r[2] + 10.0)
            .toList();
        model = MultipleLinearRegression.fit(x, y);
      });

      test('coefficients recovered', () {
        expect(model.coefficients[0], closeTo(1.0, 1e-8));
        expect(model.coefficients[1], closeTo(-2.0, 1e-8));
        expect(model.coefficients[2], closeTo(0.5, 1e-8));
      });

      test('intercept recovered', () {
        expect(model.intercept, closeTo(10.0, 1e-8));
      });

      test('R² ≈ 1', () {
        expect(model.rSquared, closeTo(1.0, 1e-8));
      });
    });

    group('noisy data', () {
      test('R² < 1 with noise', () {
        final x = [
          [1],
          [2],
          [3],
          [4],
          [5],
          [6],
          [7],
          [8],
          [9],
          [10],
        ];
        // y = 3*x + noise
        final y = [3.1, 5.9, 9.2, 11.8, 15.1, 17.9, 21.2, 23.8, 27.1, 29.9];
        final model = MultipleLinearRegression.fit(x, y);

        expect(model.rSquared, greaterThan(0.99));
        expect(model.rSquared, lessThan(1.0));
        expect(model.coefficients[0], closeTo(3.0, 0.2));
      });
    });

    group('errors', () {
      test('empty data throws', () {
        expect(
          () => MultipleLinearRegression.fit([], []),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('mismatched lengths throws', () {
        expect(
          () => MultipleLinearRegression.fit(
            [
              [1, 2],
              [3, 4],
            ],
            [1],
          ),
          throwsA(isA<DimensionMismatchException>()),
        );
      });

      test('too few observations throws', () {
        // 1 predictor needs at least 2 observations
        expect(
          () => MultipleLinearRegression.fit(
            [
              [1],
            ],
            [5],
          ),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('unequal row lengths throws', () {
        expect(
          () => MultipleLinearRegression.fit(
            [
              [1, 2],
              [3],
              [5, 6],
              [7, 8],
            ],
            [5, 6, 7, 8],
          ),
          throwsA(isA<DimensionMismatchException>()),
        );
      });

      test('predict wrong dimension throws', () {
        final model = MultipleLinearRegression.fit(
          [
            [1, 5],
            [3, 2],
            [5, 8],
          ],
          [1, 2, 3],
        );
        expect(
          () => model.predict([1]),
          throwsA(isA<DimensionMismatchException>()),
        );
      });
    });

    group('confidenceInterval', () {
      test('returns valid interval', () {
        final x = [
          [1],
          [2],
          [3],
          [4],
          [5],
          [6],
          [7],
          [8],
          [9],
          [10],
        ];
        final y = [3.1, 5.9, 9.2, 11.8, 15.1, 17.9, 21.2, 23.8, 27.1, 29.9];
        final model = MultipleLinearRegression.fit(x, y);

        final ci = model.confidenceInterval([5], 0.95);
        final predicted = model.predict([5]);

        expect(ci.lower, lessThan(predicted));
        expect(ci.upper, greaterThan(predicted));
      });
    });

    group('toJson / fromJson', () {
      test('round-trip', () {
        final x = [
          [1, 5],
          [3, 2],
          [5, 8],
          [7, 1],
        ];
        final y = [11, 7, 21, 9];
        final model = MultipleLinearRegression.fit(x, y);

        final json = model.toJson();
        final restored = MultipleLinearRegression.fromJson(json);

        expect(restored.intercept, model.intercept);
        expect(restored.coefficients, model.coefficients);
        expect(restored.rSquared, model.rSquared);
        expect(restored.n, model.n);
        expect(restored.p, model.p);
      });
    });

    group('toString', () {
      test('contains model info', () {
        final model = MultipleLinearRegression.fit(
          [
            [1, 5],
            [3, 2],
            [5, 8],
            [7, 1],
          ],
          [11, 7, 21, 9],
        );
        final s = model.toString();
        expect(s, contains('MultipleLinearRegression'));
        expect(s, contains('R²='));
      });
    });
  });

  group('Matrix utilities', () {
    group('matTranspose', () {
      test('2x3 → 3x2', () {
        final m = [
          [1.0, 2.0, 3.0],
          [4.0, 5.0, 6.0],
        ];
        final t = matTranspose(m);
        expect(t.length, 3);
        expect(t[0], [1.0, 4.0]);
        expect(t[1], [2.0, 5.0]);
        expect(t[2], [3.0, 6.0]);
      });

      test('empty', () {
        expect(matTranspose([]), isEmpty);
      });
    });

    group('matMultiply', () {
      test('2x2 × 2x2', () {
        final a = [
          [1.0, 2.0],
          [3.0, 4.0],
        ];
        final b = [
          [5.0, 6.0],
          [7.0, 8.0],
        ];
        final c = matMultiply(a, b);
        expect(c[0][0], closeTo(19, 1e-10));
        expect(c[0][1], closeTo(22, 1e-10));
        expect(c[1][0], closeTo(43, 1e-10));
        expect(c[1][1], closeTo(50, 1e-10));
      });

      test('incompatible dimensions throws', () {
        expect(
          () => matMultiply(
            [
              [1.0, 2.0],
            ],
            [
              [1.0],
              [2.0],
              [3.0],
            ],
          ),
          throwsA(isA<DimensionMismatchException>()),
        );
      });
    });

    group('matInverse', () {
      test('2x2 identity inverse = identity', () {
        final id = [
          [1.0, 0.0],
          [0.0, 1.0],
        ];
        final inv = matInverse(id);
        expect(inv[0][0], closeTo(1, 1e-10));
        expect(inv[0][1], closeTo(0, 1e-10));
        expect(inv[1][0], closeTo(0, 1e-10));
        expect(inv[1][1], closeTo(1, 1e-10));
      });

      test('2x2 inverse', () {
        final a = [
          [4.0, 7.0],
          [2.0, 6.0],
        ];
        // det = 24-14 = 10, inv = [0.6, -0.7; -0.2, 0.4]
        final inv = matInverse(a);
        expect(inv[0][0], closeTo(0.6, 1e-10));
        expect(inv[0][1], closeTo(-0.7, 1e-10));
        expect(inv[1][0], closeTo(-0.2, 1e-10));
        expect(inv[1][1], closeTo(0.4, 1e-10));
      });

      test('A × A⁻¹ ≈ I', () {
        final a = [
          [2.0, 1.0, 1.0],
          [4.0, 3.0, 3.0],
          [8.0, 7.0, 9.0],
        ];
        final inv = matInverse(a);
        final product = matMultiply(a, inv);

        for (var i = 0; i < 3; i++) {
          for (var j = 0; j < 3; j++) {
            expect(product[i][j], closeTo(i == j ? 1.0 : 0.0, 1e-10));
          }
        }
      });

      test('singular matrix throws', () {
        expect(
          () => matInverse([
            [1.0, 2.0],
            [2.0, 4.0],
          ]),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('empty matrix throws', () {
        expect(() => matInverse([]), throwsA(isA<InvalidInputException>()));
      });
    });
  });
}
