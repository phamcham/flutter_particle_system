import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'particle_painter.dart';
import 'particle_system.dart';

typedef ParticleSystemCreate = ParticleSystem Function(BuildContext context);

class ParticleSystemWidget extends StatefulWidget {
  /// widget sẽ huỷ particle khi dispose. Dùng để tạo ngay ParticleSystem
  const ParticleSystemWidget({super.key, required ParticleSystemCreate create})
    : _create = create,
      _value = null,
      _autoDispose = true;

  /// Tự dispose particlesystem sau khi dùng xong. Dùng khi có một tham chiếu
  /// khác tới ParticleSystem cần xử lý thủ công
  const ParticleSystemWidget.value({super.key, required ParticleSystem value})
    : _value = value,
      _create = null,
      _autoDispose = false;

  final ParticleSystemCreate? _create;
  final ParticleSystem? _value;
  final bool _autoDispose;

  @override
  State<ParticleSystemWidget> createState() => _ParticleSystemWidgetState();
}

class _ParticleSystemWidgetState extends State<ParticleSystemWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late ParticleSystem? _system;

  @override
  void initState() {
    super.initState();

    if (widget._create != null) {
      _system = widget._create!(context);
    } else {
      _system = widget._value!;
    }

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

    _system?.update(deltaTime);

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ParticleSystemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // oldWidget.particleSystem.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_system == null) return SizedBox.shrink();

    return RepaintBoundary(
      child: CustomPaint(painter: ParticlePainter(_system!)),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();

    if (widget._autoDispose) {
      _system?.dispose();
      _system = null;
    }

    super.dispose();
  }
}
