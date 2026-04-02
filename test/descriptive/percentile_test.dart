import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('median', () {
    test('odd count', () {
      expect(median([1, 2, 3]), 2.0);
    });

    test('even count', () {
      expect(median([1, 2, 3, 4]), closeTo(2.5, 1e-10));
    });

    test('unsorted input', () {
      expect(median([5, 1, 3]), 3.0);
    });

    test('single element', () {
      expect(median([42]), 42.0);
    });

    test('empty throws', () {
      expect(() => median([]), throwsA(isA<EmptyDataException>()));
    });
  });

  group('percentile', () {
    test('0th percentile is min', () {
      expect(percentile([1, 2, 3, 4, 5], 0), 1.0);
    });

    test('100th percentile is max', () {
      expect(percentile([1, 2, 3, 4, 5], 1.0), 5.0);
    });

    test('50th percentile is median', () {
      final data = [1.0, 2.0, 3.0, 4.0, 5.0];
      expect(percentile(data, 0.5), closeTo(median(data), 1e-10));
    });

    test('75th percentile', () {
      // index = 0.75 * 99 = 74.25 → 75 + 0.25*(76-75) = 75.25
      final data = List.generate(100, (i) => (i + 1).toDouble());
      expect(percentile(data, 0.75), closeTo(75.25, 1e-10));
    });

    test('25th percentile', () {
      // index = 0.25 * 99 = 24.75 → 25 + 0.75*(26-25) = 25.75
      final data = List.generate(100, (i) => (i + 1).toDouble());
      expect(percentile(data, 0.25), closeTo(25.75, 1e-10));
    });

    test('p < 0 throws', () {
      expect(
        () => percentile([1, 2, 3], -0.1),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('p > 1 throws', () {
      expect(
        () => percentile([1, 2, 3], 1.1),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('empty throws', () {
      expect(
        () => percentile([], 0.5),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });

  group('iqr', () {
    test('known dataset', () {
      final data = List.generate(100, (i) => (i + 1).toDouble());
      final q75 = percentile(data, 0.75);
      final q25 = percentile(data, 0.25);
      expect(iqr(data), closeTo(q75 - q25, 1e-10));
    });

    test('identical values → 0', () {
      expect(iqr([5, 5, 5, 5]), closeTo(0.0, 1e-10));
    });

    test('empty throws', () {
      expect(() => iqr([]), throwsA(isA<EmptyDataException>()));
    });
  });
}
