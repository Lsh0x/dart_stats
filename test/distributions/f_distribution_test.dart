import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('F distribution', () {
    group('construction', () {
      test('valid parameters', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.df1, 5.0);
        expect(f.df2, 10.0);
      });

      test('df1 <= 0 throws', () {
        expect(
          () => FDistribution(df1: 0.0, df2: 10.0),
          throwsA(isA<InvalidInputException>()),
        );
      });

      test('df2 <= 0 throws', () {
        expect(
          () => FDistribution(df1: 5.0, df2: 0.0),
          throwsA(isA<InvalidInputException>()),
        );
      });
    });

    group('properties', () {
      test('name is F', () {
        expect(FDistribution(df1: 5, df2: 10).name, 'F');
      });

      test('numParams is 2', () {
        expect(FDistribution(df1: 5, df2: 10).numParams, 2);
      });

      test('mean = df2/(df2-2) for df2 > 2', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.distMean, closeTo(10.0 / 8.0, 1e-10));
      });

      test('mean is NaN for df2 <= 2', () {
        expect(FDistribution(df1: 5.0, df2: 2.0).distMean, isNaN);
      });
    });

    group('pdf', () {
      test('pdf(x<=0) = 0', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.pdf(0.0), 0.0);
        expect(f.pdf(-1.0), 0.0);
      });

      test('F(5,10) pdf(1)', () {
        // f(1; 5, 10) = exp(2.5*ln(0.5) - 7.5*ln(1.5) - lnB(2.5,5)) ≈ 0.4955
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.pdf(1.0), closeTo(0.4955, 1e-3));
      });
    });

    group('cdf', () {
      test('cdf(x<=0) = 0', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.cdf(0.0), 0.0);
      });

      test('cdf increases monotonically', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        var prev = 0.0;
        for (var x = 0.1; x <= 10.0; x += 0.5) {
          final c = f.cdf(x);
          expect(c, greaterThanOrEqualTo(prev));
          prev = c;
        }
      });

      test('F(5,10) cdf(3.33) ≈ 0.95 (F-table)', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(f.cdf(3.33), closeTo(0.95, 0.01));
      });
    });

    group('inverseCdf', () {
      test('roundtrip: cdf(inverseCdf(p)) ≈ p', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        for (final p in [0.1, 0.25, 0.5, 0.75, 0.9, 0.95]) {
          expect(f.cdf(f.inverseCdf(p)), closeTo(p, 1e-5));
        }
      });

      test('p out of range throws', () {
        final f = FDistribution(df1: 5.0, df2: 10.0);
        expect(() => f.inverseCdf(0.0), throwsA(isA<InvalidInputException>()));
        expect(() => f.inverseCdf(1.0), throwsA(isA<InvalidInputException>()));
      });
    });

    test('toString', () {
      expect(
        FDistribution(df1: 5.0, df2: 10.0).toString(),
        'F(df1=5.0, df2=10.0)',
      );
    });
  });
}
