import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('gini', () {
    test('all equal → 0', () {
      expect(gini([5, 5, 5, 5]), closeTo(0.0, 1e-10));
    });

    test('maximum inequality', () {
      // [0, 0, 0, 100] → Gini close to 0.75 (for n=4)
      // Exact: (2*(1*0+2*0+3*0+4*100))/(4*100) - 5/4 = 800/400 - 1.25 = 0.75
      expect(gini([0, 0, 0, 100]), closeTo(0.75, 1e-10));
    });

    test('known value', () {
      // [1, 2, 3, 4, 5]
      // totalSum = 15, weightedSum = 1+4+9+16+25 = 55
      // G = 2*55/(5*15) - 6/5 = 110/75 - 1.2 = 1.4667 - 1.2 = 0.2667
      expect(gini([1, 2, 3, 4, 5]), closeTo(4.0 / 15, 1e-10));
    });

    test('bounded in [0, 1)', () {
      final g = gini([1, 1, 1, 1, 100]);
      expect(g, greaterThanOrEqualTo(0));
      expect(g, lessThan(1));
    });

    test('all zeros → 0', () {
      expect(gini([0, 0, 0]), closeTo(0.0, 1e-10));
    });

    test('order-independent', () {
      expect(gini([1, 5, 3, 2, 4]), closeTo(gini([1, 2, 3, 4, 5]), 1e-10));
    });

    test('negative values throw', () {
      expect(
        () => gini([1, -2, 3]),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('empty list throws', () {
      expect(() => gini([]), throwsA(isA<EmptyDataException>()));
    });
  });
}
