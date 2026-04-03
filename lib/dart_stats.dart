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
export 'src/distributions/beta.dart';
export 'src/distributions/binomial.dart';
export 'src/distributions/chi_squared.dart';
export 'src/distributions/discrete_distribution.dart';
export 'src/distributions/distribution.dart';
export 'src/distributions/exponential.dart';
export 'src/distributions/f_distribution.dart';
export 'src/distributions/fitting.dart';
export 'src/distributions/gamma.dart';
export 'src/distributions/geometric.dart';
export 'src/distributions/lognormal.dart';
export 'src/distributions/negative_binomial.dart';
export 'src/distributions/normal.dart';
export 'src/distributions/poisson.dart';
export 'src/distributions/student_t.dart';
export 'src/distributions/uniform.dart';
export 'src/distributions/weibull.dart';

// Errors
export 'src/errors.dart';

// Hypothesis tests
export 'src/hypothesis/anova.dart';
export 'src/hypothesis/chi_square.dart';
export 'src/hypothesis/t_test.dart';

// Regression
export 'src/regression/linear_regression.dart';
export 'src/regression/multiple_linear_regression.dart';

// Utils
export 'src/utils/combinatorics.dart';
export 'src/utils/constants.dart';
export 'src/utils/matrix.dart';
export 'src/utils/numeric.dart';
export 'src/utils/special_functions.dart';
