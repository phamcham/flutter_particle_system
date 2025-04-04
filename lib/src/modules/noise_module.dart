import 'package:fast_noise/fast_noise.dart';

class NoiseModule {
  final int seed;
  final double frequency;
  final double strength;

  final PerlinNoise _perlinNoise;

  NoiseModule({
    required this.seed,
    required this.frequency,
    required this.strength,
  }) : _perlinNoise = PerlinNoise(seed: seed, frequency: frequency);

  double getDouble(double x, double y) {
    return _perlinNoise.getNoise2(x, y) * strength;
  }
}
