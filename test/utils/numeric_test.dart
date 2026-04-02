import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('approxEqual', () {
    test('equal values', () {
      expect(approxEqual(1.0, 1.0), isTrue);
    });

    test('close values within epsilon', () {
      expect(approxEqual(1.0, 1.0 + 1e-10, epsilon: 1e-9), isTrue);
    });

    test('different values outside epsilon', () {
      expect(approxEqual(1.0, 1.1, epsilon: 1e-9), isFalse);
    });

    test('default epsilon is 1e-10', () {
      expect(approxEqual(1.0, 1.0 + 1e-11), isTrue);
      expect(approxEqual(1.0, 1.0 + 1e-9), isFalse);
    });
  });

  group('safeLog', () {
    test('log of positive number', () {
      expect(safeLog(1.0), 0.0);
      expect(safeLog(2.718281828459045), closeTo(1.0, 1e-10));
    });

    test('log of 0 throws', () {
      expect(() => safeLog(0.0), throwsA(isA<InvalidInputException>()));
    });

    test('log of negative throws', () {
      expect(() => safeLog(-1.0), throwsA(isA<InvalidInputException>()));
    });
  });
}
