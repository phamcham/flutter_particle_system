import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'particle_painter.dart';
import 'particle_system.dart';

class ParticleSystemWidget extends StatefulWidget {
  const ParticleSystemWidget({
    super.key,
    required this.create,
    required this.debug,
  });

  final ParticleSystem Function(BuildContext context) create;
  final bool debug;

  @override
  State<ParticleSystemWidget> createState() => _ParticleSystemWidgetState();
}

class _ParticleSystemWidgetState extends State<ParticleSystemWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Ticker _ticker;
  late ParticleSystem _system;

  @override
  void initState() {
    super.initState();

    _system = widget.create(context);
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

    _system.update(deltaTime);

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ParticleSystemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // oldWidget.particleSystem.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: CustomPaint(
        painter: ParticlePainter(_system, debug: widget.debug),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }
}
