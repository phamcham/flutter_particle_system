import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'particle_painter.dart';
import 'particle_system.dart';

class ParticleSystemWidget extends StatefulWidget {
  const ParticleSystemWidget({
    super.key,
    required this.particleSystem,
    required this.debug,
  });

  final ParticleSystem particleSystem;
  final bool debug;

  @override
  State<ParticleSystemWidget> createState() => _ParticleSystemWidgetState();
}

class _ParticleSystemWidgetState extends State<ParticleSystemWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_tick)..start();
  }

  Duration? _lastFrameTime;

  void _tick(Duration elapsed) {
    if (_lastFrameTime == null) {
      _lastFrameTime = elapsed;
      return;
    }

    double deltaTime = (elapsed - _lastFrameTime!).inMilliseconds / 1000.0;
    _lastFrameTime = elapsed;

    widget.particleSystem.update(deltaTime);

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ParticleSystemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // oldWidget.particleSystem.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        widget.particleSystem,
        debug: widget.debug,
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.particleSystem.dispose();
    super.dispose();
  }
}
