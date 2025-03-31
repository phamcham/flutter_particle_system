import 'particle_system.dart';

class ParticleSystemGroup {
  final List<ParticleSystem> _particleSystems = [];

  ParticleSystemGroup();

  void add(ParticleSystem system) {
    if (_particleSystems.contains(system)) return;
    _particleSystems.add(system);
  }

  void remove(ParticleSystem system) {
    _particleSystems.remove(system);
  }

  void clearAll() {
    for (final system in _particleSystems) {
      system.clear();
    }
  }

  void resetAll() {
    for (final system in _particleSystems) {
      system.reset();
    }
  }

  void disposeAll() {
    for (final system in _particleSystems) {
      system.dispose();
    }
  }

  void playAll() {
    for (final system in _particleSystems) {
      system.play();
    }
  }

  void stopAll() {
    for (final system in _particleSystems) {
      system.stop();
    }
  }
}
