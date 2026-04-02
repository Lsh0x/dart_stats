import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('StatsException', () {
    test('EmptyDataException has default message', () {
      const e = EmptyDataException();
      expect(e.message, 'Data must not be empty');
      expect(e.toString(), contains('EmptyDataException'));
    });

    test('EmptyDataException accepts custom message', () {
      const e = EmptyDataException('Need at least 2 elements');
      expect(e.message, 'Need at least 2 elements');
    });

    test('InvalidInputException stores message', () {
      const e = InvalidInputException('sigma must be positive');
      expect(e.message, 'sigma must be positive');
      expect(e.toString(), contains('InvalidInputException'));
    });

    test('DimensionMismatchException stores message', () {
      const e = DimensionMismatchException('x and y must have same length');
      expect(e.message, 'x and y must have same length');
    });

    test('NumericalException stores message', () {
      const e = NumericalException('overflow in gamma function');
      expect(e.message, 'overflow in gamma function');
    });

    test('NotFittedException has default message', () {
      const e = NotFittedException();
      expect(e.message, 'Model must be fitted before use');
    });

    test('all exceptions are StatsException', () {
      expect(const EmptyDataException(), isA<StatsException>());
      expect(
        const InvalidInputException('x'),
        isA<StatsException>(),
      );
      expect(
        const DimensionMismatchException('x'),
        isA<StatsException>(),
      );
      expect(const NumericalException('x'), isA<StatsException>());
      expect(const NotFittedException(), isA<StatsException>());
    });
  });
}
