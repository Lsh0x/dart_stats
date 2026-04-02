import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Distribution fitting', () {
    group('fitAll', () {
      test('returns results sorted by AIC', () {
        final rng = math.Random(42);
        final data = List.generate(
          200,
          (_) => 5.0 + 2.0 * _boxMullerZ(rng),
        );
        final results = fitAll(data);
        expect(results, isNotEmpty);

        // Check sorted by AIC
        for (var i = 1; i < results.length; i++) {
          expect(results[i].aic, greaterThanOrEqualTo(results[i - 1].aic));
        }
      });

      test('Normal data → Normal wins', () {
        final rng = math.Random(42);
        final data = List.generate(
          500,
          (_) => 10.0 + 3.0 * _boxMullerZ(rng),
        );
        final results = fitAll(data);
        expect(results.first.name, 'Normal');
      });

      test('each result has name, aic, bic', () {
        final data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
        final results = fitAll(data);
        for (final r in results) {
          expect(r.name, isNotEmpty);
          expect(r.aic, isA<double>());
          expect(r.bic, isA<double>());
          expect(r.distribution, isA<Distribution>());
        }
      });

      test('empty data throws', () {
        expect(() => fitAll([]), throwsA(isA<EmptyDataException>()));
      });
    });

    group('fitBest', () {
      test('returns single best result', () {
        final rng = math.Random(42);
        final data = List.generate(
          200,
          (_) => 5.0 + 2.0 * _boxMullerZ(rng),
        );
        final best = fitBest(data);
        expect(best.name, isNotEmpty);
        expect(best.distribution, isA<Distribution>());
      });
    });

    group('autoFit', () {
      test('normal data → Normal', () {
        final rng = math.Random(42);
        final data = List.generate(
          500,
          (_) => 10.0 + 3.0 * _boxMullerZ(rng),
        );
        final result = autoFit(data);
        expect(result.name, 'Normal');
      });

      test('exponential data → Exponential', () {
        final rng = math.Random(42);
        final data = List.generate(
          500,
          (_) => -math.log(rng.nextDouble()) / 2.0,
        );
        final result = autoFit(data);
        expect(result.name, 'Exponential');
      });
    });

    group('ksTest', () {
      test('good fit → high p-value', () {
        final rng = math.Random(42);
        final data = List.generate(
          200,
          (_) => 5.0 + 2.0 * _boxMullerZ(rng),
        );
        final fitted = Normal.fit(data);
        final result = ksTest(data, fitted.cdf);
        expect(result.pValue, greaterThan(0.05));
        expect(result.statistic, greaterThan(0));
        expect(result.statistic, lessThan(1));
      });

      test('bad fit → low p-value', () {
        final rng = math.Random(42);
        // Exponential data tested against Normal CDF
        final data = List.generate(
          200,
          (_) => -math.log(rng.nextDouble()),
        );
        final wrongFit = Normal(mu: 0, sigma: 1);
        final result = ksTest(data, wrongFit.cdf);
        expect(result.pValue, lessThan(0.05));
      });

      test('empty data throws', () {
        expect(
          () => ksTest([], (x) => x),
          throwsA(isA<EmptyDataException>()),
        );
      });
    });
  });
}

double _boxMullerZ(math.Random rng) {
  final u1 = rng.nextDouble();
  final u2 = rng.nextDouble();
  return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
}
