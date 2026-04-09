import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('ewma', () {
    test('first value equals data[0]', () {
      final result = ewma([10, 20, 30], alpha: 0.5);
      expect(result.values[0], closeTo(10.0, 1e-10));
    });

    test('known computation', () {
      // alpha = 0.5, data = [10, 20, 30]
      // EWMA[0] = 10
      // EWMA[1] = 0.5*20 + 0.5*10 = 15
      // EWMA[2] = 0.5*30 + 0.5*15 = 22.5
      final result = ewma([10, 20, 30], alpha: 0.5);
      expect(result.values[0], closeTo(10.0, 1e-10));
      expect(result.values[1], closeTo(15.0, 1e-10));
      expect(result.values[2], closeTo(22.5, 1e-10));
    });

    test('alpha = 1 → no smoothing (values = data)', () {
      final result = ewma([5, 10, 15, 20], alpha: 1.0);
      expect(result.values, [5, 10, 15, 20]);
    });

    test('small alpha = heavy smoothing', () {
      final result = ewma([100, 0, 0, 0, 0], alpha: 0.1);
      // Values should decay slowly from 100
      expect(result.values[0], 100.0);
      expect(result.values[1], closeTo(90.0, 1e-10)); // 0.1*0 + 0.9*100
      // Each subsequent value converges toward 0
      for (var i = 2; i < result.values.length; i++) {
        expect(result.values[i], lessThan(result.values[i - 1]));
      }
    });

    test('same length as input', () {
      final result = ewma([1, 2, 3, 4, 5]);
      expect(result.values.length, 5);
    });

    test('stores alpha', () {
      final result = ewma([1, 2, 3], alpha: 0.7);
      expect(result.alpha, 0.7);
    });

    test('constant data → constant EWMA', () {
      final result = ewma([5, 5, 5, 5, 5], alpha: 0.3);
      for (final v in result.values) {
        expect(v, closeTo(5.0, 1e-10));
      }
    });

    test('empty data throws', () {
      expect(() => ewma([]), throwsA(isA<EmptyDataException>()));
    });

    test('alpha = 0 throws', () {
      expect(
        () => ewma([1, 2, 3], alpha: 0),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('alpha > 1 throws', () {
      expect(
        () => ewma([1, 2, 3], alpha: 1.5),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
