/// Base exception for all dart_stats errors.
sealed class StatsException implements Exception {
  const StatsException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when input data is empty or has insufficient elements.
class EmptyDataException extends StatsException {
  const EmptyDataException([super.message = 'Data must not be empty']);
}

/// Thrown when input parameters are invalid.
class InvalidInputException extends StatsException {
  const InvalidInputException(super.message);
}

/// Thrown when array dimensions do not match.
class DimensionMismatchException extends StatsException {
  const DimensionMismatchException(super.message);
}

/// Thrown when a numerical computation fails (overflow, NaN, etc.).
class NumericalException extends StatsException {
  const NumericalException(super.message);
}

/// Thrown when a model is used before fitting.
class NotFittedException extends StatsException {
  const NotFittedException([super.message = 'Model must be fitted before use']);
}
