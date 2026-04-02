# dart_stats

[![CI](https://github.com/Lsh0x/dart_stats/actions/workflows/ci.yml/badge.svg)](https://github.com/Lsh0x/dart_stats/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Pure Dart statistics library. Zero dependencies.

Port of [rs-stats](https://github.com/Lsh0x/rs-stats) (Rust) adapted to Dart conventions.

## Features

- **Descriptive statistics** — mean, variance, standard deviation, standard error, z-score, percentile, median, IQR
- **Probability distributions** — Normal, LogNormal, Exponential, Uniform with PDF, CDF, inverse CDF, and MLE fitting
- **Distribution fitting** — `autoFit`, `fitAll` with AIC/BIC ranking and Kolmogorov-Smirnov goodness-of-fit test
- **Linear regression** — fit, predict, confidence intervals, r-squared, correlation coefficient
- **Hypothesis tests** — paired t-test, one-sample t-test
- **Utility functions** — gamma, beta, erf/erfc, combinatorics

## Install

```yaml
dependencies:
  dart_stats:
    git:
      url: https://github.com/Lsh0x/dart_stats.git
      ref: main
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
  print('Trend: ${reg.slope.toStringAsFixed(1)}€/month (r²=${reg.rSquared.toStringAsFixed(3)})');
  print('Predicted month 12: ${reg.predict(12).toStringAsFixed(0)}€');

  // Distribution fitting
  final result = autoFit(expenses);
  print('Best fit: ${result.name} (AIC=${result.aic.toStringAsFixed(1)})');

  // Anomaly detection
  final avg = mean(expenses);
  final sd = stdDev(expenses);
  final suspicious = 890.0;
  print('z-score of $suspicious: ${zScore(suspicious, avg, sd).toStringAsFixed(2)}');
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

### Distributions

Each distribution provides: `pdf(x)`, `cdf(x)`, `inverseCdf(p)`, `fit(data)`, `mean`, `variance`, `logLikelihood(data)`, `aic(data)`, `bic(data)`.

| Class | Parameters |
|-------|-----------|
| `Normal` | mu, sigma |
| `LogNormal` | mu, sigma |
| `Exponential` | lambda |
| `Uniform` | min, max |

### Fitting

| Function | Description |
|----------|-------------|
| `autoFit(data)` | Best-fit distribution (lowest AIC) |
| `fitAll(data)` | All distributions ranked by AIC |
| `ksTest(data, cdf)` | Kolmogorov-Smirnov goodness-of-fit |

### Regression

| Class | Description |
|-------|-------------|
| `LinearRegression` | Simple OLS: `fit`, `predict`, `confidenceInterval`, `rSquared`, `correlationCoefficient` |

### Hypothesis Tests

| Function | Description |
|----------|-------------|
| `pairedTTest(before, after)` | Paired t-test (p-value for mean difference) |
| `oneSampleTTest(data, mu)` | One-sample t-test |

## License

MIT
