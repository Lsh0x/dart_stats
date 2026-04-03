import '../errors.dart';

/// Transposes a matrix.
List<List<double>> matTranspose(List<List<double>> a) {
  if (a.isEmpty) return [];
  final rows = a.length;
  final cols = a[0].length;
  return List.generate(cols, (j) => List.generate(rows, (i) => a[i][j]));
}

/// Multiplies two matrices.
///
/// [a] is m×n, [b] is n×p → result is m×p.
List<List<double>> matMultiply(List<List<double>> a, List<List<double>> b) {
  final m = a.length;
  final n = a[0].length;
  final p = b[0].length;

  if (b.length != n) {
    throw DimensionMismatchException(
      'matMultiply: incompatible dimensions '
      '(${m}x$n) × (${b.length}x$p)',
    );
  }

  final result = List.generate(m, (_) => List.filled(p, 0.0));

  for (var i = 0; i < m; i++) {
    for (var k = 0; k < n; k++) {
      final aik = a[i][k];
      for (var j = 0; j < p; j++) {
        result[i][j] += aik * b[k][j];
      }
    }
  }

  return result;
}

/// Multiplies a matrix by a column vector.
///
/// [a] is m×n, [v] has length n → result has length m.
List<double> matVecMultiply(List<List<double>> a, List<double> v) {
  final m = a.length;
  final n = a[0].length;

  if (v.length != n) {
    throw DimensionMismatchException(
      'matVecMultiply: incompatible dimensions '
      '(${m}x$n) × (${v.length})',
    );
  }

  final result = List.filled(m, 0.0);
  for (var i = 0; i < m; i++) {
    var sum = 0.0;
    for (var j = 0; j < n; j++) {
      sum += a[i][j] * v[j];
    }
    result[i] = sum;
  }
  return result;
}

/// Inverts a square matrix using Gauss-Jordan elimination.
///
/// Throws [InvalidInputException] if the matrix is singular.
List<List<double>> matInverse(List<List<double>> a) {
  final n = a.length;
  if (n == 0) {
    throw const InvalidInputException('matInverse: empty matrix');
  }
  for (final row in a) {
    if (row.length != n) {
      throw const InvalidInputException('matInverse: matrix must be square');
    }
  }

  // Augmented matrix [A | I]
  final aug = List.generate(
    n,
    (i) => [...a[i], ...List.generate(n, (j) => i == j ? 1.0 : 0.0)],
  );

  // Forward elimination with partial pivoting
  for (var col = 0; col < n; col++) {
    // Find pivot
    var maxVal = aug[col][col].abs();
    var maxRow = col;
    for (var row = col + 1; row < n; row++) {
      final val = aug[row][col].abs();
      if (val > maxVal) {
        maxVal = val;
        maxRow = row;
      }
    }

    if (maxVal < 1e-14) {
      throw const InvalidInputException('matInverse: singular matrix');
    }

    // Swap rows
    if (maxRow != col) {
      final temp = aug[col];
      aug[col] = aug[maxRow];
      aug[maxRow] = temp;
    }

    // Scale pivot row
    final pivot = aug[col][col];
    for (var j = col; j < 2 * n; j++) {
      aug[col][j] /= pivot;
    }

    // Eliminate column
    for (var row = 0; row < n; row++) {
      if (row == col) continue;
      final factor = aug[row][col];
      for (var j = col; j < 2 * n; j++) {
        aug[row][j] -= factor * aug[col][j];
      }
    }
  }

  // Extract inverse from augmented matrix
  return List.generate(n, (i) => aug[i].sublist(n));
}
