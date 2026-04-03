import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Distribution fitting', () {
    // ---------------------------------------------------------------
    // Continuous fitting
    // ---------------------------------------------------------------
    group('fitAll', () {
      test('returns results sorted by AIC', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => 5.0 + 2.0 * _boxMullerZ(rng));
        final results = fitAll(data);
        expect(results, isNotEmpty);

        for (var i = 1; i < results.length; i++) {
          expect(results[i].aic, greaterThanOrEqualTo(results[i - 1].aic));
        }
      });

      test('Normal data → Normal wins', () {
        final rng = math.Random(42);
        final data = List.generate(500, (_) => 10.0 + 3.0 * _boxMullerZ(rng));
        final results = fitAll(data);
        expect(results.first.name, 'Normal');
      });

      test('includes Gamma, Beta, Weibull candidates', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => rng.nextDouble() * 10 + 0.1);
        final results = fitAll(data);
        final names = results.map((r) => r.name).toSet();
        // At least some of the new distributions should appear
        expect(
          names.intersection({'Gamma', 'Beta', 'Weibull'}).isNotEmpty,
          isTrue,
        );
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

      test('Gamma data → Gamma or Weibull wins', () {
        final rng = math.Random(42);
        // Gamma(shape=2, rate=1) data
        final data = List.generate(500, (_) {
          // Sum of 2 exponentials = Gamma(2,1)
          return -math.log(rng.nextDouble()) - math.log(rng.nextDouble());
        });
        final best = fitBest(data);
        expect(
          ['Gamma', 'Weibull', 'LogNormal'].contains(best.name),
          isTrue,
          reason: 'Gamma-like data should fit Gamma, Weibull, or LogNormal',
        );
      });
    });

    group('fitBest', () {
      test('returns single best result', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => 5.0 + 2.0 * _boxMullerZ(rng));
        final best = fitBest(data);
        expect(best.name, isNotEmpty);
        expect(best.distribution, isA<Distribution>());
      });
    });

    group('autoFit', () {
      test('normal data → Normal', () {
        final rng = math.Random(42);
        final data = List.generate(500, (_) => 10.0 + 3.0 * _boxMullerZ(rng));
        final result = autoFit(data);
        expect(result.name, 'Normal');
      });

      test('exponential data → Exponential or Gamma', () {
        final rng = math.Random(42);
        final data = List.generate(
          500,
          (_) => -math.log(rng.nextDouble()) / 2.0,
        );
        final result = autoFit(data);
        // Exponential is Gamma(1,λ), so either may win
        expect(['Exponential', 'Gamma'].contains(result.name), isTrue);
      });
    });

    // ---------------------------------------------------------------
    // Discrete fitting
    // ---------------------------------------------------------------
    group('fitAllDiscrete', () {
      test('returns results sorted by AIC', () {
        final rng = math.Random(42);
        // Poisson-like data (lambda ≈ 5)
        final data = List.generate(200, (_) => _poissonSample(rng, 5.0));
        final results = fitAllDiscrete(data);
        expect(results, isNotEmpty);

        for (var i = 1; i < results.length; i++) {
          expect(results[i].aic, greaterThanOrEqualTo(results[i - 1].aic));
        }
      });

      test('Poisson data → Poisson wins', () {
        final rng = math.Random(42);
        final data = List.generate(500, (_) => _poissonSample(rng, 3.0));
        final results = fitAllDiscrete(data);
        expect(results.first.name, 'Poisson');
      });

      test('each result has name, aic, bic', () {
        final data = [0, 1, 2, 3, 1, 2, 0, 1, 3, 2];
        final results = fitAllDiscrete(data);
        for (final r in results) {
          expect(r.name, isNotEmpty);
          expect(r.aic, isA<double>());
          expect(r.bic, isA<double>());
          expect(r.distribution, isA<DiscreteDistribution>());
        }
      });

      test('empty data throws', () {
        expect(() => fitAllDiscrete([]), throwsA(isA<EmptyDataException>()));
      });

      test('Geometric data → Geometric wins', () {
        final rng = math.Random(42);
        // Geometric(p=0.3): count failures before success
        final data = List.generate(500, (_) {
          var k = 0;
          while (rng.nextDouble() > 0.3) {
            k++;
          }
          return k;
        });
        final results = fitAllDiscrete(data);
        // Geometric should be best or among top
        final bestNames = results.take(2).map((r) => r.name).toSet();
        expect(
          bestNames.contains('Geometric') ||
              bestNames.contains('NegativeBinomial'),
          isTrue,
          reason: 'Geometric data should fit Geometric or NegBinom',
        );
      });
    });

    group('fitBestDiscrete', () {
      test('returns single best result', () {
        final data = [0, 1, 2, 3, 1, 2, 0, 1, 3, 2];
        final best = fitBestDiscrete(data);
        expect(best.name, isNotEmpty);
        expect(best.distribution, isA<DiscreteDistribution>());
      });

      test('empty data throws', () {
        expect(() => fitBestDiscrete([]), throwsA(isA<EmptyDataException>()));
      });
    });

    group('isDiscreteData', () {
      test('all integers → true', () {
        expect(isDiscreteData([1, 2, 3, 4, 5]), isTrue);
        expect(isDiscreteData([0.0, 1.0, 2.0]), isTrue);
      });

      test('fractional values → false', () {
        expect(isDiscreteData([1.5, 2.0, 3.0]), isFalse);
        expect(isDiscreteData([0.1]), isFalse);
      });

      test('empty → true', () {
        expect(isDiscreteData([]), isTrue);
      });
    });

    // ---------------------------------------------------------------
    // KS tests
    // ---------------------------------------------------------------
    group('ksTest', () {
      test('good fit → high p-value', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => 5.0 + 2.0 * _boxMullerZ(rng));
        final fitted = Normal.fit(data);
        final result = ksTest(data, fitted.cdf);
        expect(result.pValue, greaterThan(0.05));
        expect(result.statistic, greaterThan(0));
        expect(result.statistic, lessThan(1));
      });

      test('bad fit → low p-value', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => -math.log(rng.nextDouble()));
        final wrongFit = Normal(mu: 0, sigma: 1);
        final result = ksTest(data, wrongFit.cdf);
        expect(result.pValue, lessThan(0.05));
      });

      test('empty data throws', () {
        expect(() => ksTest([], (x) => x), throwsA(isA<EmptyDataException>()));
      });
    });

    group('ksTestDiscrete', () {
      test('good fit → reasonable statistic', () {
        final rng = math.Random(42);
        final data = List.generate(200, (_) => _poissonSample(rng, 5.0));
        final fitted = Poisson.fit(data);
        final result = ksTestDiscrete(data, fitted);
        // Discrete KS is conservative — just check statistic is small
        expect(result.statistic, greaterThan(0));
        expect(result.statistic, lessThan(0.5));
      });

      test('bad fit → low p-value', () {
        final rng = math.Random(42);
        // High-variance data vs Poisson (which has mean=var)
        final data = List.generate(200, (_) => rng.nextInt(100));
        final wrongFit = Poisson(lambda: 1.0);
        final result = ksTestDiscrete(data, wrongFit);
        expect(result.pValue, lessThan(0.05));
      });

      test('empty data throws', () {
        expect(
          () => ksTestDiscrete([], Poisson(lambda: 1)),
          throwsA(isA<EmptyDataException>()),
        );
      });
    });

    // ---------------------------------------------------------------
    // FitResult / DiscreteFitResult toString
    // ---------------------------------------------------------------
    group('toString', () {
      test('FitResult toString', () {
        final r = fitBest([1.0, 2.0, 3.0, 4.0, 5.0]);
        expect(r.toString(), contains('FitResult'));
        expect(r.toString(), contains('AIC='));
      });

      test('DiscreteFitResult toString', () {
        final r = fitBestDiscrete([0, 1, 2, 3, 1, 2]);
        expect(r.toString(), contains('DiscreteFitResult'));
        expect(r.toString(), contains('AIC='));
      });

      test('KsResult toString', () {
        const r = KsResult(statistic: 0.05, pValue: 0.9);
        expect(r.toString(), contains('D='));
        expect(r.toString(), contains('p='));
      });
    });
  });
}

/// Box-Muller normal random.
double _boxMullerZ(math.Random rng) {
  final u1 = rng.nextDouble();
  final u2 = rng.nextDouble();
  return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
}

/// Simple Poisson random variate via inverse transform.
int _poissonSample(math.Random rng, double lambda) {
  final l = math.exp(-lambda);
  var k = 0;
  var p = 1.0;
  do {
    k++;
    p *= rng.nextDouble();
  } while (p > l);
  return k - 1;
}
