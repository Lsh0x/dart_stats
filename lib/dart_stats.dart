/// Pure Dart statistics library.
///
/// Provides descriptive statistics, probability distributions with fitting,
/// linear regression, and hypothesis tests. Zero dependencies.
library;

// Descriptive statistics
export 'src/descriptive/average.dart';
export 'src/descriptive/percentile.dart';
export 'src/descriptive/std_dev.dart';
export 'src/descriptive/std_err.dart';
export 'src/descriptive/variance.dart';
export 'src/descriptive/z_score.dart';

// Distributions
export 'src/distributions/distribution.dart';
export 'src/distributions/lognormal.dart';
export 'src/distributions/normal.dart';

// Errors
export 'src/errors.dart';

// Hypothesis tests
export 'src/hypothesis/t_test.dart';

// Regression
export 'src/regression/linear_regression.dart';

// Utils
export 'src/utils/combinatorics.dart';
export 'src/utils/constants.dart';
export 'src/utils/numeric.dart';
export 'src/utils/special_functions.dart';
