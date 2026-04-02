import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('variance (population)', () {
    test('known dataset', () {
      // [2,4,4,4,5,5,7,9] → population variance = 4.0
      expect(
        variance([2, 4, 4, 4, 5, 5, 7, 9]),
        closeTo(4.0, 1e-10),
      );
    });

    test('identical values → 0', () {
      expect(variance([5, 5, 5, 5]), closeTo(0.0, 1e-10));
    });

    test('single element → 0', () {
      expect(variance([42]), closeTo(0.0, 1e-10));
    });

    test('empty list throws', () {
      expect(() => variance([]), throwsA(isA<EmptyDataException>()));
    });
  });

  group('sampleVariance', () {
    test('known dataset', () {
      // [2,4,4,4,5,5,7,9] → sample variance = 32/7 ≈ 4.571428
      expect(
        sampleVariance([2, 4, 4, 4, 5, 5, 7, 9]),
        closeTo(32.0 / 7.0, 1e-10),
      );
    });

    test('two elements', () {
      // [0, 10] → mean=5, sample var = 50
      expect(sampleVariance([0, 10]), closeTo(50.0, 1e-10));
    });

    test('single element throws (n-1 = 0)', () {
      expect(
        () => sampleVariance([42]),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('empty list throws', () {
      expect(
        () => sampleVariance([]),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });
}
