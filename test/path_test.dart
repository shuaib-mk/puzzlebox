import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlebox/games/strands/path_generator.dart';

void main() {
  test(
    'Winding Strands paths cover every cell once and retain the spangram',
    () {
      final initial = [
        for (var r = 0; r < 8; r++)
          for (var c = 0; c < 6; c++) r * 6 + (r.isEven ? c : 5 - c),
      ];
      for (var seed = 0; seed < 200; seed++) {
        final path = weavePath(initial, 9, 240, Random(seed));
        expect(path.toSet(), List.generate(48, (i) => i).toSet());
        expect(path.take(9), initial.take(9));
        for (var i = 1; i < path.length; i++) {
          expect((path[i] ~/ 6 - path[i - 1] ~/ 6).abs(), lessThanOrEqualTo(1));
          expect((path[i] % 6 - path[i - 1] % 6).abs(), lessThanOrEqualTo(1));
        }
      }
    },
  );
}
