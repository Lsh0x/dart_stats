import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('mean', () {
    test('simple integers', () {
      expect(mean([1, 2, 3, 4, 5]), 3.0);
    });

    test('simple doubles', () {
      expect(mean([1.5, 2.5, 3.5]), closeTo(2.5, 1e-10));
    });

    test('single element', () {
      expect(mean([42]), 42.0);
    });

    test('negative values', () {
      expect(mean([-1, 0, 1]), closeTo(0.0, 1e-10));
    });

    test('large dataset', () {
      final data = List.generate(1000, (i) => i.toDouble());
      expect(mean(data), closeTo(499.5, 1e-10));
    });

    test('empty list throws', () {
      expect(() => mean([]), throwsA(isA<EmptyDataException>()));
    });
  });
}
