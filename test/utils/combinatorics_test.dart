import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('factorial', () {
    test('factorial(0) == 1', () {
      expect(factorial(0), 1);
    });

    test('factorial(1) == 1', () {
      expect(factorial(1), 1);
    });

    test('factorial(5) == 120', () {
      expect(factorial(5), 120);
    });

    test('factorial(10) == 3628800', () {
      expect(factorial(10), 3628800);
    });

    test('factorial(20) == 2432902008176640000', () {
      expect(factorial(20), 2432902008176640000);
    });

    test('factorial(-1) throws', () {
      expect(() => factorial(-1), throwsA(isA<InvalidInputException>()));
    });

    test('factorial(21) throws (overflow)', () {
      expect(() => factorial(21), throwsA(isA<InvalidInputException>()));
    });
  });

  group('permutation', () {
    test('P(5,2) == 20', () {
      expect(permutation(5, 2), 20);
    });

    test('P(5,0) == 1', () {
      expect(permutation(5, 0), 1);
    });

    test('P(5,5) == 120', () {
      expect(permutation(5, 5), 120);
    });

    test('P(3,4) throws (k > n)', () {
      expect(() => permutation(3, 4), throwsA(isA<InvalidInputException>()));
    });

    test('P(-1,2) throws', () {
      expect(
        () => permutation(-1, 2),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('combination', () {
    test('C(5,2) == 10', () {
      expect(combination(5, 2), 10);
    });

    test('C(5,0) == 1', () {
      expect(combination(5, 0), 1);
    });

    test('C(5,5) == 1', () {
      expect(combination(5, 5), 1);
    });

    test('C(10,3) == 120', () {
      expect(combination(10, 3), 120);
    });

    test('C(n,k) == C(n,n-k) symmetry', () {
      expect(combination(10, 3), combination(10, 7));
    });

    test('C(3,4) throws (k > n)', () {
      expect(() => combination(3, 4), throwsA(isA<InvalidInputException>()));
    });
  });
}
