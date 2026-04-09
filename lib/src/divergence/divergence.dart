import 'dart:math' as math;

import '../errors.dart';

/// Kullback-Leibler divergence from distribution [p] to [q].
///
/// DKL(P || Q) = Σ p(i) × ln(p(i) / q(i))
///
/// **Not symmetric**: DKL(P||Q) ≠ DKL(Q||P).
///
/// [p] and [q] are discrete probability distributions (must sum to ≈1).
/// Returns [double.infinity] if any q(i) = 0 where p(i) > 0.
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [InvalidInputException] if distributions contain negative values.
double klDivergence(List<double> p, List<double> q) {
  _validateDistributions(p, q);

  var sum = 0.0;
  for (var i = 0; i < p.length; i++) {
    if (p[i] == 0) continue;
    if (q[i] == 0) return double.infinity;
    sum += p[i] * math.log(p[i] / q[i]);
  }
  return sum;
}

/// Jensen-Shannon divergence between distributions [p] and [q].
///
/// JSD(P || Q) = ½ DKL(P || M) + ½ DKL(Q || M)
/// where M = ½(P + Q).
///
/// **Symmetric**, bounded in [0, ln(2)] ≈ [0, 0.693].
/// The square root (√JSD) is a proper metric (Jensen-Shannon distance).
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [InvalidInputException] if distributions contain negative values.
double jsDivergence(List<double> p, List<double> q) {
  _validateDistributions(p, q);

  final m = List<double>.generate(p.length, (i) => (p[i] + q[i]) / 2);

  var klPm = 0.0;
  var klQm = 0.0;
  for (var i = 0; i < p.length; i++) {
    if (p[i] > 0 && m[i] > 0) {
      klPm += p[i] * math.log(p[i] / m[i]);
    }
    if (q[i] > 0 && m[i] > 0) {
      klQm += q[i] * math.log(q[i] / m[i]);
    }
  }
  return (klPm + klQm) / 2;
}

/// Jensen-Shannon distance (square root of JS divergence).
///
/// √JSD is a proper metric: satisfies triangle inequality.
/// Bounded in [0, √ln(2)] ≈ [0, 0.832].
double jsDistance(List<double> p, List<double> q) {
  return math.sqrt(jsDivergence(p, q));
}

/// Hellinger distance between distributions [p] and [q].
///
/// H(P, Q) = (1/√2) × √(Σ (√p(i) − √q(i))²)
///
/// Bounded in [0, 1]. A proper metric.
/// Related to Bhattacharyya coefficient: H² = 1 − BC.
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [InvalidInputException] if distributions contain negative values.
double hellingerDistance(List<double> p, List<double> q) {
  _validateDistributions(p, q);

  var sum = 0.0;
  for (var i = 0; i < p.length; i++) {
    final diff = math.sqrt(p[i]) - math.sqrt(q[i]);
    sum += diff * diff;
  }
  return math.sqrt(sum / 2);
}

/// Bhattacharyya coefficient between distributions [p] and [q].
///
/// BC(P, Q) = Σ √(p(i) × q(i))
///
/// Bounded in [0, 1]. BC = 1 means identical distributions.
/// Related to Hellinger: H² = 1 − BC.
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [InvalidInputException] if distributions contain negative values.
double bhattacharyyaCoefficient(List<double> p, List<double> q) {
  _validateDistributions(p, q);

  var sum = 0.0;
  for (var i = 0; i < p.length; i++) {
    sum += math.sqrt(p[i] * q[i]);
  }
  return sum;
}

/// Total variation distance between distributions [p] and [q].
///
/// TV(P, Q) = ½ Σ |p(i) − q(i)|
///
/// Bounded in [0, 1]. Equal to the largest possible difference in
/// probability assigned to a single event.
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [InvalidInputException] if distributions contain negative values.
double totalVariationDistance(List<double> p, List<double> q) {
  _validateDistributions(p, q);

  var sum = 0.0;
  for (var i = 0; i < p.length; i++) {
    sum += (p[i] - q[i]).abs();
  }
  return sum / 2;
}

// ── validation ──

void _validateDistributions(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw DimensionMismatchException(
      'Distributions must have same length: ${p.length} ≠ ${q.length}',
    );
  }
  if (p.isEmpty) {
    throw const EmptyDataException('Distributions must not be empty');
  }
  for (var i = 0; i < p.length; i++) {
    if (p[i] < 0 || q[i] < 0) {
      throw InvalidInputException(
        'Probabilities must be non-negative at index $i: p=${p[i]}, q=${q[i]}',
      );
    }
  }
}
