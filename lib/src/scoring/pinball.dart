import '../errors.dart';

/// Pinball loss (quantile loss) for a single prediction.
///
/// Measures how well a predicted quantile matches the actual value.
/// Lower = better.
///
/// For quantile τ:
///   L(y, ŷ, τ) = τ × max(0, y − ŷ) + (1−τ) × max(0, ŷ − y)
///
/// If actual > predicted (undershoot): penalized by τ.
/// If actual < predicted (overshoot): penalized by (1−τ).
///
/// [quantile] must be in (0, 1).
///
/// Throws [InvalidInputException] if [quantile] is not in (0, 1).
double pinballLoss(double predicted, double actual, double quantile) {
  if (quantile <= 0 || quantile >= 1) {
    throw InvalidInputException(
      'Quantile must be in (0, 1), got $quantile',
    );
  }

  final diff = actual - predicted;
  if (diff >= 0) {
    return quantile * diff;
  } else {
    return (1 - quantile) * (-diff);
  }
}

/// Mean pinball loss over a list of predictions.
///
/// [predicted] and [actual] must have the same length.
///
/// Throws [DimensionMismatchException] if lengths differ.
/// Throws [EmptyDataException] if lists are empty.
/// Throws [InvalidInputException] if [quantile] is not in (0, 1).
double meanPinballLoss(
  List<double> predicted,
  List<double> actual,
  double quantile,
) {
  if (predicted.length != actual.length) {
    throw DimensionMismatchException(
      'Predicted and actual must have same length: '
      '${predicted.length} ≠ ${actual.length}',
    );
  }
  if (predicted.isEmpty) {
    throw const EmptyDataException('Cannot compute loss on empty lists');
  }

  var sum = 0.0;
  for (var i = 0; i < predicted.length; i++) {
    sum += pinballLoss(predicted[i], actual[i], quantile);
  }
  return sum / predicted.length;
}
