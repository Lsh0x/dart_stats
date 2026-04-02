import 'dart:math' as math;

import '../errors.dart';

/// Lanczos coefficients for g=7, n=9.
const List<double> _lanczosCoefficients = [
  0.99999999999980993,
  676.5203681218851,
  -1259.1392167224028,
  771.32342877765313,
  -176.61502916214059,
  12.507343278686905,
  -0.13857109526572012,
  9.9843695780195716e-6,
  1.5056327351493116e-7,
];

/// Natural logarithm of the Gamma function.
///
/// Uses Lanczos approximation with g=7, accurate to ~15 digits.
/// Throws [InvalidInputException] for non-positive integers.
double lnGamma(double x) {
  if (x <= 0 && x == x.truncateToDouble()) {
    throw InvalidInputException(
      'lnGamma is undefined for non-positive integers, got x=$x',
    );
  }

  if (x < 0.5) {
    // Reflection formula: Gamma(x) * Gamma(1-x) = pi / sin(pi*x)
    return math.log(math.pi / math.sin(math.pi * x)) - lnGamma(1.0 - x);
  }

  final xx = x - 1.0;
  var sum = _lanczosCoefficients[0];
  for (var i = 1; i < _lanczosCoefficients.length; i++) {
    sum += _lanczosCoefficients[i] / (xx + i);
  }

  const g = 7.0;
  final t = xx + g + 0.5;

  return 0.5 * math.log(2 * math.pi) +
      (xx + 0.5) * math.log(t) -
      t +
      math.log(sum);
}

/// Gamma function Γ(x).
///
/// Returns exp(lnGamma(x)).
double gammaFn(double x) => math.exp(lnGamma(x));

/// Error function erf(x).
///
/// Uses Abramowitz & Stegun approximation (formula 7.1.26),
/// maximum error ≈ 1.5 × 10⁻⁷.
double erf(double x) {
  // erf is an odd function
  final sign = x < 0 ? -1.0 : 1.0;
  final ax = x.abs();

  const a1 = 0.254829592;
  const a2 = -0.284496736;
  const a3 = 1.421413741;
  const a4 = -1.453152027;
  const a5 = 1.061405429;
  const p = 0.3275911;

  final t = 1.0 / (1.0 + p * ax);
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;
  final t5 = t4 * t;

  final y = 1.0 -
      (a1 * t + a2 * t2 + a3 * t3 + a4 * t4 + a5 * t5) * math.exp(-ax * ax);

  return sign * y;
}

/// Complementary error function erfc(x) = 1 - erf(x).
double erfc(double x) => 1.0 - erf(x);

/// Regularized lower incomplete gamma function P(a, x).
///
/// P(a, x) = γ(a, x) / Γ(a) where γ is the lower incomplete gamma.
/// Uses series expansion for x < a+1, continued fraction otherwise.
double regularizedIncompleteGamma(double a, double x) {
  if (x < 0) {
    throw InvalidInputException(
      'regularizedIncompleteGamma requires x >= 0, got x=$x',
    );
  }
  if (a <= 0) {
    throw InvalidInputException(
      'regularizedIncompleteGamma requires a > 0, got a=$a',
    );
  }

  if (x == 0) return 0.0;

  if (x < a + 1.0) {
    return _gammaSeries(a, x);
  } else {
    return 1.0 - _gammaContinuedFraction(a, x);
  }
}

/// Series expansion for P(a, x).
double _gammaSeries(double a, double x) {
  final lnGammaA = lnGamma(a);
  var sum = 1.0 / a;
  var term = 1.0 / a;

  for (var n = 1; n < 200; n++) {
    term *= x / (a + n);
    sum += term;
    if (term.abs() < sum.abs() * 1e-14) break;
  }

  return sum * math.exp(-x + a * math.log(x) - lnGammaA);
}

/// Continued fraction for Q(a, x) = 1 - P(a, x).
/// Uses Lentz's algorithm.
double _gammaContinuedFraction(double a, double x) {
  final lnGammaA = lnGamma(a);
  const tiny = 1e-30;

  var f = tiny;
  var c = f;
  var d = 0.0;

  for (var n = 1; n < 200; n++) {
    final an = n.isOdd
        ? ((n + 1) ~/ 2).toDouble() // (n+1)/2 for odd n
        : -(a - 1.0 + n ~/ 2); // -(a-1+n/2) for even n

    final bn = n == 1 ? x + 1.0 - a : x + 2.0 * n - 1.0 - a;

    d = bn + an * d;
    if (d.abs() < tiny) d = tiny;
    d = 1.0 / d;

    c = bn + an / c;
    if (c.abs() < tiny) c = tiny;

    final delta = c * d;
    f *= delta;

    if ((delta - 1.0).abs() < 1e-14) break;
  }

  return f * math.exp(-x + a * math.log(x) - lnGammaA);
}

/// Beta function B(a, b) = Γ(a)Γ(b) / Γ(a+b).
double betaFn(double a, double b) => math.exp(lnBeta(a, b));

/// Natural logarithm of the Beta function.
/// ln B(a, b) = lnΓ(a) + lnΓ(b) - lnΓ(a+b).
double lnBeta(double a, double b) => lnGamma(a) + lnGamma(b) - lnGamma(a + b);

/// Regularized incomplete beta function I_x(a, b).
///
/// Uses the continued fraction representation (Lentz's algorithm).
double regularizedIncompleteBeta(double a, double b, double x) {
  if (x < 0 || x > 1) {
    throw InvalidInputException(
      'regularizedIncompleteBeta requires 0 <= x <= 1, got x=$x',
    );
  }
  if (a <= 0 || b <= 0) {
    throw InvalidInputException(
      'regularizedIncompleteBeta requires a > 0 and b > 0, '
      'got a=$a, b=$b',
    );
  }

  if (x == 0) return 0.0;
  if (x == 1) return 1.0;

  // Use symmetry: I_x(a,b) = 1 - I_{1-x}(b,a) when x > (a+1)/(a+b+2)
  if (x > (a + 1.0) / (a + b + 2.0)) {
    return 1.0 - regularizedIncompleteBeta(b, a, 1.0 - x);
  }

  final lnPrefactor = -lnBeta(a, b) + a * math.log(x) + b * math.log(1.0 - x);
  final prefactor = math.exp(lnPrefactor);

  return prefactor * _betaContinuedFraction(a, b, x) / a;
}

/// Continued fraction for I_x(a, b) using Lentz's algorithm.
double _betaContinuedFraction(double a, double b, double x) {
  const tiny = 1e-30;
  const maxIter = 200;

  var c = 1.0;
  var d = 1.0 / (1.0 - (a + b) * x / (a + 1.0)).clamp(tiny, double.infinity);
  if (d.abs() < tiny) d = tiny;
  var f = d;

  for (var m = 1; m <= maxIter; m++) {
    // Even step: d_{2m}
    final mDouble = m.toDouble();
    final denom = (a + 2.0 * mDouble - 1.0) * (a + 2.0 * mDouble);
    var numerator = mDouble * (b - mDouble) * x / denom;

    d = 1.0 + numerator * d;
    if (d.abs() < tiny) d = tiny;
    d = 1.0 / d;

    c = 1.0 + numerator / c;
    if (c.abs() < tiny) c = tiny;

    f *= c * d;

    // Odd step: d_{2m+1}
    numerator = -(a + mDouble) *
        (a + b + mDouble) *
        x /
        ((a + 2.0 * mDouble) * (a + 2.0 * mDouble + 1.0));

    d = 1.0 + numerator * d;
    if (d.abs() < tiny) d = tiny;
    d = 1.0 / d;

    c = 1.0 + numerator / c;
    if (c.abs() < tiny) c = tiny;

    final delta = c * d;
    f *= delta;

    if ((delta - 1.0).abs() < 1e-14) break;
  }

  return f;
}

/// Generic bisection method to invert a CDF.
///
/// Finds x such that cdf(x) ≈ p, searching in [lo, hi].
/// Throws [InvalidInputException] if p is not in (0, 1).
double bisectInverseCdf(
  double Function(double) cdf,
  double p, {
  required double lo,
  required double hi,
  double tolerance = 1e-10,
  int maxIterations = 200,
}) {
  if (p <= 0 || p >= 1) {
    throw InvalidInputException(
      'bisectInverseCdf requires 0 < p < 1, got p=$p',
    );
  }

  var low = lo;
  var high = hi;

  for (var i = 0; i < maxIterations; i++) {
    final mid = (low + high) / 2.0;
    final value = cdf(mid);

    if ((value - p).abs() < tolerance) return mid;

    if (value < p) {
      low = mid;
    } else {
      high = mid;
    }
  }

  return (low + high) / 2.0;
}
