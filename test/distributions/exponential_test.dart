import 'dart:math' as math;

import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Exponential distribution', () {
    late Exponential d;

    setUp(() {
      d = Exponential(lambda: 1);
    });

    group('construction', () {
      test('lambda = 1', () {
        expect(d.lambda, 1);
      });

      test('lambda <= 0 throws', () {
        expect(
          () => Exponential(lambda: 0),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => Exponential(lambda: -1),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('mean = 1/lambda', () {
        expect(Exponential(lambda: 2).distMean, closeTo(0.5, 1e-10));
      });

      test('variance = 1/lambda^2', () {
        expect(
          Exponential(lambda: 2).distVariance,
          closeTo(0.25, 1e-10),
        );
      });

      test('name is Exponential', () {
        expect(d.name, 'Exponential');
      });

      test('numParams is 1', () {
        expect(d.numParams, 1);
      });
    });

    group('pdf', () {
      test('pdf(0) = lambda', () {
        expect(d.pdf(0), closeTo(1.0, 1e-10));
      });

      test('pdf(1) = e^-1', () {
        expect(d.pdf(1), closeTo(math.exp(-1), 1e-10));
      });

      test('pdf negative = 0', () {
        expect(d.pdf(-1), 0.0);
      });
    });

    group('cdf', () {
      test('cdf(0) = 0', () {
        expect(d.cdf(0), closeTo(0.0, 1e-10));
      });

      test('cdf(1) = 1 - e^-1 ≈ 0.6321', () {
        expect(d.cdf(1), closeTo(1 - math.exp(-1), 1e-10));
      });

      test('cdf negative = 0', () {
        expect(d.cdf(-1), 0.0);
      });
    });

    group('inverseCdf', () {
      test('inverseCdf(0.5) = ln(2)/lambda', () {
        expect(d.inverseCdf(0.5), closeTo(math.ln2, 1e-10));
      });

      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(d.cdf(d.inverseCdf(p)), closeTo(p, 1e-10));
        }
      });
    });

    group('fit', () {
      test('fit recovers lambda from exponential data', () {
        final rng = math.Random(42);
        // Inverse transform: -ln(U)/lambda
        final data = List.generate(
          1000,
          (_) => -math.log(rng.nextDouble()) / 2.0,
        );
        final fitted = Exponential.fit(data);
        expect(fitted.lambda, closeTo(2.0, 0.2));
      });

      test('fit empty throws', () {
        expect(
          () => Exponential.fit([]),
          throwsA(isA<EmptyDataException>()),
        );
      });

      test('fit with non-positive values throws', () {
        expect(
          () => Exponential.fit([1, 2, -1]),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });
  });
}
