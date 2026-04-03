// ignore_for_file: avoid_print

import 'package:dart_stats/dart_stats.dart';

void main() {
  // ── Descriptive statistics ─────────────────────────────────
  final expenses = [420.0, 435.0, 410.0, 450.0, 470.0, 460.0, 440.0, 430.0];

  print('=== Monthly Expenses Analysis ===');
  print('Mean:      ${mean(expenses).toStringAsFixed(2)}');
  print('Median:    ${median(expenses).toStringAsFixed(2)}');
  print('Std Dev:   ${stdDev(expenses).toStringAsFixed(2)}');
  print('IQR:       ${iqr(expenses).toStringAsFixed(2)}');
  print('');

  // ── Anomaly detection via z-score ──────────────────────────
  final avg = mean(expenses);
  final sd = sampleStdDev(expenses);
  const suspicious = 890.0;
  final z = zScore(suspicious, avg, sd);
  print('=== Anomaly Detection ===');
  print('Transaction: $suspicious');
  print('z-score:     ${z.toStringAsFixed(2)}');
  print('Anomaly:     ${z.abs() > 2 ? "YES" : "no"}');
  print('');

  // ── Trend analysis with linear regression ──────────────────
  final months = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0];
  final reg = LinearRegression.fit(months, expenses);

  print('=== Spending Trend ===');
  print('Slope:     +${reg.slope.toStringAsFixed(2)}/month');
  print('R-squared: ${reg.rSquared.toStringAsFixed(3)}');
  print('Month 12:  ${reg.predict(12).toStringAsFixed(0)} (predicted)');

  final ci = reg.confidenceInterval(12, 0.95);
  print(
    '95% CI:    [${ci.lower.toStringAsFixed(0)}, '
    '${ci.upper.toStringAsFixed(0)}]',
  );
  print('');

  // ── Distribution fitting ───────────────────────────────────
  print('=== Distribution Fitting ===');
  final results = fitAll(expenses);
  for (final r in results) {
    print('  ${r.name.padRight(12)} AIC=${r.aic.toStringAsFixed(1)}');
  }
  final best = results.first;
  print('Best fit: ${best.name}');

  // Use the fitted distribution for probability queries
  final dist = best.distribution;
  final prob = 1 - dist.cdf(500);
  print('P(expenses > 500) = ${(prob * 100).toStringAsFixed(1)}%');

  final budget95 = dist.inverseCdf(0.95);
  print('95th percentile budget: ${budget95.toStringAsFixed(0)}');
  print('');

  // ── Before/after comparison with paired t-test ─────────────
  final before = [200.0, 210.0, 220.0, 215.0, 205.0, 225.0];
  final after = [180.0, 185.0, 190.0, 195.0, 180.0, 200.0];

  print('=== Budget Change Impact ===');
  final test = pairedTTest(before, after);
  print('Mean diff:  ${test.meanDiff.toStringAsFixed(1)}');
  print('t-stat:     ${test.tStatistic.toStringAsFixed(3)}');
  print('p-value:    ${test.pValue.toStringAsFixed(4)}');
  print('Significant (p<0.05): ${test.pValue < 0.05 ? "YES" : "no"}');
}
