import 'package:dart_stats/dart_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Distribution interface', () {
    test('Normal implements Distribution', () {
      final d = Normal(mu: 0, sigma: 1);
      expect(d, isA<Distribution>());
    });

    test('LogNormal implements Distribution', () {
      final d = LogNormal(mu: 0, sigma: 1);
      expect(d, isA<Distribution>());
    });
  });
}
