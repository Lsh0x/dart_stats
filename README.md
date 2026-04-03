# dart_stats

[![CI](https://github.com/Lsh0x/dart_stats/actions/workflows/ci.yml/badge.svg)](https://github.com/Lsh0x/dart_stats/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Pure Dart statistics library. Zero dependencies.

Port of [rs-stats](https://github.com/Lsh0x/rs-stats) (Rust) adapted to Dart conventions.

## Features

- **Descriptive statistics** — mean, variance, standard deviation, standard error, z-score, percentile, median, IQR
- **Continuous distributions** — Normal, LogNormal, Exponential, Uniform, Gamma, Beta, ChiSquared, StudentT, F, Weibull with PDF, CDF, inverse CDF, and MLE fitting
- **Discrete distributions** — Binomial, Poisson, Geometric, NegativeBinomial with PMF, CDF, inverse CDF, and MLE fitting
- **Distribution fitting** — `autoFit`, `fitAll`, `fitAllDiscrete` with AIC/BIC ranking and Kolmogorov-Smirnov tests
- **Linear regression** — simple and multiple OLS, predict, confidence intervals, R-squared
- **Hypothesis tests** — t-tests (one-sample, paired, two-sample Welch), one-way ANOVA, chi-square (goodness-of-fit, independence)
- **Utility functions** — gamma, beta, erf/erfc, regularized incomplete beta/gamma, matrix operations, combinatorics

## Install

```yaml
dependencies:
  dart_stats:
    git:
      url: https://github.com/Lsh0x/dart_stats.git
      ref: v0.2.0
```

## Quick Start

```dart
import 'package:dart_stats/dart_stats.dart';

void main() {
  // Descriptive stats
  final data = [23.0, 45.0, 12.0, 67.0, 34.0, 89.0, 56.0];
  print('Mean: ${mean(data)}');
  print('Std Dev: ${stdDev(data)}');
  print('Median: ${median(data)}');

  // Linear regression
  final months = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
  final expenses = [420.0, 435.0, 410.0, 450.0, 470.0, 460.0];
  final reg = LinearRegression.fit(months, expenses);
  print('Trend: ${reg.slope.toStringAsFixed(1)}/month (r2=${reg.rSquared.toStringAsFixed(3)})');

  // Multiple regression
  final x = [[1, 100], [2, 150], [3, 200], [4, 250], [5, 300]];
  final y = [10.0, 15.0, 20.0, 25.0, 30.0];
  final mlr = MultipleLinearRegression.fit(x, y);
  print('R2=${mlr.rSquared.toStringAsFixed(4)}');

  // Distribution fitting
  final result = autoFit(expenses);
  print('Best fit: ${result.name} (AIC=${result.aic.toStringAsFixed(1)})');

  // Hypothesis test
  final g1 = [5.0, 7.0, 9.0, 8.0, 6.0];
  final g2 = [2.0, 4.0, 3.0, 5.0, 4.0];
  final g3 = [8.0, 9.0, 10.0, 7.0, 8.0];
  final anova = oneWayAnova([g1, g2, g3]);
  print('ANOVA: F=${anova.fStatistic.toStringAsFixed(2)}, p=${anova.pValue.toStringAsFixed(4)}');
}
```

## API Overview

### Descriptive

| Function | Description |
|----------|-------------|
| `mean(data)` | Arithmetic mean |
| `variance(data)` | Population variance (Welford's algorithm) |
| `sampleVariance(data)` | Sample variance (Bessel's correction) |
| `stdDev(data)` | Population standard deviation |
| `sampleStdDev(data)` | Sample standard deviation |
| `stdErr(data)` | Standard error of the mean |
| `zScore(x, mean, stdDev)` | Z-score standardization |
| `median(data)` | Median value |
| `percentile(data, p)` | p-th percentile (0.0 to 1.0) |
| `iqr(data)` | Interquartile range |

### Continuous Distributions

Each provides: `pdf(x)`, `cdf(x)`, `inverseCdf(p)`, `fit(data)`, `distMean`, `distVariance`, `logLikelihood`, `aic`, `bic`.

| Class | Parameters |
|-------|-----------|
| `Normal` | mu, sigma |
| `LogNormal` | mu, sigma |
| `Exponential` | lambda |
| `Uniform` | min, max |
| `GammaDistribution` | alpha (shape), beta (rate) |
| `Beta` | alpha, beta |
| `ChiSquared` | df |
| `StudentT` | df |
| `FDistribution` | df1, df2 |
| `Weibull` | k (shape), lambda (scale) |

### Discrete Distributions

Each provides: `pmf(k)`, `cdf(k)`, `inverseCdf(p)`, `fit(data)`, `distMean`, `distVariance`, `logLikelihood`, `aic`, `bic`.

| Class | Parameters |
|-------|-----------|
| `Binomial` | n, p |
| `Poisson` | lambda |
| `Geometric` | p |
| `NegativeBinomial` | r, p |

### Fitting

| Function | Description |
|----------|-------------|
| `autoFit(data)` | Best-fit continuous distribution (lowest AIC) |
| `fitAll(data)` | All continuous distributions ranked by AIC |
| `fitBest(data)` | Same as autoFit |
| `fitAllDiscrete(data)` | All discrete distributions ranked by AIC |
| `fitBestDiscrete(data)` | Best-fit discrete distribution |
| `isDiscreteData(data)` | Detect if data is integer-valued |
| `ksTest(data, cdf)` | Kolmogorov-Smirnov goodness-of-fit |
| `ksTestDiscrete(data, dist)` | KS-like test for discrete distributions |

### Regression

| Class | Description |
|-------|-------------|
| `LinearRegression` | Simple OLS: `fit`, `predict`, `confidenceInterval`, `rSquared`, `correlationCoefficient` |
| `MultipleLinearRegression` | Multiple OLS: `fit`, `predict`, `predictMany`, `rSquared`, `adjustedRSquared`, `residuals`, `confidenceInterval` |

### Hypothesis Tests

| Function | Description |
|----------|-------------|
| `oneSampleTTest(data, mu)` | One-sample t-test |
| `pairedTTest(before, after)` | Paired t-test |
| `twoSampleTTest(a, b)` | Two-sample Welch's t-test |
| `oneWayAnova(groups)` | One-way ANOVA (F-test) |
| `chiSquareGoodnessOfFit(obs, exp)` | Chi-square goodness-of-fit |
| `chiSquareIndependence(matrix)` | Chi-square independence test |

### Utils

| Function | Description |
|----------|-------------|
| `gammaFn(x)`, `lnGamma(x)` | Gamma function |
| `betaFn(a,b)`, `lnBeta(a,b)` | Beta function |
| `erf(x)`, `erfc(x)` | Error function |
| `regularizedIncompleteBeta(a,b,x)` | Regularized incomplete beta |
| `regularizedIncompleteGamma(a,x)` | Regularized incomplete gamma |
| `factorial(n)`, `binomial(n,k)` | Combinatorics |
| `matTranspose`, `matMultiply`, `matInverse` | Matrix operations |

## License

MIT
