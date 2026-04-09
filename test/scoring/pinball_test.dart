import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('pinballLoss', () {
    test('perfect prediction → 0', () {
      expect(pinballLoss(10, 10, 0.5), closeTo(0.0, 1e-10));
    });

    test('undershoot at median (τ=0.5)', () {
      // predicted=8, actual=10, τ=0.5 → 0.5 * (10-8) = 1.0
      expect(pinballLoss(8, 10, 0.5), closeTo(1.0, 1e-10));
    });

    test('overshoot at median (τ=0.5)', () {
      // predicted=12, actual=10, τ=0.5 → 0.5 * (12-10) = 1.0
      expect(pinballLoss(12, 10, 0.5), closeTo(1.0, 1e-10));
    });

    test('asymmetric: undershoot penalized more at high quantile', () {
      // τ=0.9: undershoot is expensive, overshoot is cheap
      final under = pinballLoss(80, 100, 0.9); // 0.9 * 20 = 18
      final over = pinballLoss(120, 100, 0.9); // 0.1 * 20 = 2
      expect(under, greaterThan(over));
      expect(under, closeTo(18, 1e-10));
      expect(over, closeTo(2, 1e-10));
    });

    test('asymmetric: overshoot penalized more at low quantile', () {
      // τ=0.1: overshoot is expensive
      final under = pinballLoss(80, 100, 0.1); // 0.1 * 20 = 2
      final over = pinballLoss(120, 100, 0.1); // 0.9 * 20 = 18
      expect(over, greaterThan(under));
    });

    test('invalid quantile throws', () {
      expect(
        () => pinballLoss(10, 10, 0),
        throwsA(isA<InvalidInputException>()),
      );
      expect(
        () => pinballLoss(10, 10, 1),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('meanPinballLoss', () {
    test('perfect predictions → 0', () {
      expect(
        meanPinballLoss([10, 20, 30], [10, 20, 30], 0.5),
        closeTo(0.0, 1e-10),
      );
    });

    test('known value', () {
      // pred=[10,20], actual=[12,18], τ=0.5
      // loss1 = 0.5*2 = 1.0 (under)
      // loss2 = 0.5*2 = 1.0 (over)
      // mean = 1.0
      expect(
        meanPinballLoss([10, 20], [12, 18], 0.5),
        closeTo(1.0, 1e-10),
      );
    });

    test('dimension mismatch throws', () {
      expect(
        () => meanPinballLoss([1, 2], [1, 2, 3], 0.5),
        throwsA(isA<DimensionMismatchException>()),
      );
    });

    test('empty lists throw', () {
      expect(
        () => meanPinballLoss([], [], 0.5),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });
}
