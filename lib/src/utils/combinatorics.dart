import '../errors.dart';

/// Lookup table for factorials 0! through 20!.
const List<int> _factorialTable = [
  1, // 0!
  1, // 1!
  2, // 2!
  6, // 3!
  24, // 4!
  120, // 5!
  720, // 6!
  5040, // 7!
  40320, // 8!
  362880, // 9!
  3628800, // 10!
  39916800, // 11!
  479001600, // 12!
  6227020800, // 13!
  87178291200, // 14!
  1307674368000, // 15!
  20922789888000, // 16!
  355687428096000, // 17!
  6402373705728000, // 18!
  121645100408832000, // 19!
  2432902008176640000, // 20!
];

/// Returns n! (n factorial).
///
/// Valid for 0 ≤ n ≤ 20. Throws [InvalidInputException] otherwise.
int factorial(int n) {
  if (n < 0 || n > 20) {
    throw InvalidInputException(
      'factorial(n) requires 0 <= n <= 20, got n=$n',
    );
  }
  return _factorialTable[n];
}

/// Returns P(n, k) = n! / (n-k)!, the number of k-permutations of n.
///
/// Throws [InvalidInputException] if n < 0, k < 0, or k > n.
int permutation(int n, int k) {
  if (n < 0 || k < 0) {
    throw InvalidInputException(
      'permutation requires n >= 0 and k >= 0, got n=$n, k=$k',
    );
  }
  if (k > n) {
    throw InvalidInputException(
      'permutation requires k <= n, got n=$n, k=$k',
    );
  }
  var result = 1;
  for (var i = n; i > n - k; i--) {
    result *= i;
  }
  return result;
}

/// Returns C(n, k) = n! / (k! * (n-k)!), the binomial coefficient.
///
/// Uses symmetry optimization: C(n, k) == C(n, n-k).
/// Throws [InvalidInputException] if n < 0, k < 0, or k > n.
int combination(int n, int k) {
  if (n < 0 || k < 0) {
    throw InvalidInputException(
      'combination requires n >= 0 and k >= 0, got n=$n, k=$k',
    );
  }
  if (k > n) {
    throw InvalidInputException(
      'combination requires k <= n, got n=$n, k=$k',
    );
  }
  // Symmetry optimization
  var kk = k;
  if (kk > n - kk) {
    kk = n - kk;
  }
  var result = 1;
  for (var i = 0; i < kk; i++) {
    result = result * (n - i) ~/ (i + 1);
  }
  return result;
}
