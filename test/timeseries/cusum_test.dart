import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('cusum', () {
    test('constant data → no change points', () {
      final result = cusum([5, 5, 5, 5, 5, 5, 5, 5]);
      expect(result.changePoints, isEmpty);
    });

    test('detects upward shift', () {
      // 20 values at 10, then 20 values at 20 (clear upward shift)
      final data = [
        ...List.filled(20, 10),
        ...List.filled(20, 20),
      ];
      final result = cusum(data, target: 10.0, threshold: 15.0, slack: 2.0);
      expect(result.upwardChangePoints, isNotEmpty);
      // Change should be detected somewhere after index 20
      expect(result.upwardChangePoints.first, greaterThanOrEqualTo(20));
    });

    test('detects downward shift', () {
      final data = [
        ...List.filled(20, 20),
        ...List.filled(20, 10),
      ];
      final result = cusum(data, target: 20.0, threshold: 15.0, slack: 2.0);
      expect(result.downwardChangePoints, isNotEmpty);
      expect(result.downwardChangePoints.first, greaterThanOrEqualTo(20));
    });

    test('changePoints combines up + down sorted', () {
      final data = [
        ...List.filled(20, 10),
        ...List.filled(20, 30),
        ...List.filled(20, 5),
      ];
      final result = cusum(data, target: 10.0, threshold: 20.0, slack: 3.0);
      final all = result.changePoints;
      // Should be sorted
      for (var i = 1; i < all.length; i++) {
        expect(all[i], greaterThanOrEqualTo(all[i - 1]));
      }
    });

    test('upper and lower have same length as data', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = cusum(data);
      expect(result.upper.length, data.length);
      expect(result.lower.length, data.length);
    });

    test('target defaults to mean', () {
      final data = [10, 10, 10, 10, 10];
      final result = cusum(data);
      expect(result.target, closeTo(10.0, 1e-10));
    });

    test('cumulative sums are non-negative', () {
      final data = [1, 5, 2, 8, 3, 9, 1, 7, 2, 6];
      final result = cusum(data);
      for (final v in result.upper) {
        expect(v, greaterThanOrEqualTo(0));
      }
      for (final v in result.lower) {
        expect(v, greaterThanOrEqualTo(0));
      }
    });

    test('fewer than 2 elements throws', () {
      expect(() => cusum([5]), throwsA(isA<EmptyDataException>()));
    });
  });
}
