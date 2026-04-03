import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Uniform distribution', () {
    late Uniform d;

    setUp(() {
      d = Uniform(min: 0, max: 1);
    });

    group('construction', () {
      test('default 0-1', () {
        expect(d.min, 0);
        expect(d.max, 1);
      });

      test('min >= max throws', () {
        expect(
          () => Uniform(min: 5, max: 5),
          throwsA(isA<InvalidInputException>()),
        );
        expect(
          () => Uniform(min: 5, max: 3),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('mean = (min+max)/2', () {
        expect(Uniform(min: 2, max: 8).distMean, closeTo(5.0, 1e-10));
      });

      test('variance = (max-min)^2/12', () {
        expect(Uniform(min: 0, max: 12).distVariance, closeTo(12.0, 1e-10));
      });

      test('name is Uniform', () {
        expect(d.name, 'Uniform');
      });

      test('numParams is 2', () {
        expect(d.numParams, 2);
      });
    });

    group('pdf', () {
      test('inside range = 1/(max-min)', () {
        final u = Uniform(min: 2, max: 5);
        expect(u.pdf(3), closeTo(1.0 / 3.0, 1e-10));
      });

      test('outside range = 0', () {
        expect(d.pdf(-0.1), 0.0);
        expect(d.pdf(1.1), 0.0);
      });

      test('at boundaries', () {
        expect(d.pdf(0), closeTo(1.0, 1e-10));
        expect(d.pdf(1), closeTo(1.0, 1e-10));
      });
    });

    group('cdf', () {
      test('cdf below min = 0', () {
        expect(d.cdf(-1), 0.0);
      });

      test('cdf above max = 1', () {
        expect(d.cdf(2), 1.0);
      });

      test('cdf(0.5) = 0.5 for U(0,1)', () {
        expect(d.cdf(0.5), closeTo(0.5, 1e-10));
      });
    });

    group('inverseCdf', () {
      test('inverseCdf(0.5) = midpoint', () {
        expect(d.inverseCdf(0.5), closeTo(0.5, 1e-10));
      });

      test('roundtrip', () {
        final u = Uniform(min: 3, max: 7);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9]) {
          expect(u.cdf(u.inverseCdf(p)), closeTo(p, 1e-10));
        }
      });
    });

    group('fit', () {
      test('fit recovers min/max', () {
        final data = [2.1, 3.5, 7.9, 5.0, 2.0, 8.0];
        final fitted = Uniform.fit(data);
        expect(fitted.min, closeTo(2.0, 1e-10));
        expect(fitted.max, closeTo(8.0, 1e-10));
      });

      test('fit empty throws', () {
        expect(() => Uniform.fit([]), throwsA(isA<EmptyDataException>()));
      });

      test('fit single element throws', () {
        expect(() => Uniform.fit([5]), throwsA(isA<EmptyDataException>()));
      });
    });
  });
}
