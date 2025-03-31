import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../package_bundle.dart';

final _softCircleTexturePath = 'assets/particles/particle_soft_circle.png';
TextureLoader createSoftCircleTexture() => TextureLoader(
  loadBytes: () async {
    final byteData = await packageBundle.load(_softCircleTexturePath);
    final bytes = byteData.buffer.asUint8List();
    return bytes;
  },
);

class TextureLoader {
  final Future<Uint8List?> Function() loadBytes;

  TextureLoader({required this.loadBytes}) {
    _loadImage();
  }

  bool _loading = true;
  bool get loading => _loading;

  ui.Image? _result;
  ui.Image? get result => _result;

  bool _disposed = false;

  Future<void> _loadImage() async {
    _loading = true;
    final bytes = await loadBytes();
    if (bytes != null) {
      _result = await _bytesToImage(bytes);
    }

    if (_disposed) {
      /// load giữa chừng mà dispose
      _result?.dispose();
    }
    _loading = false;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _result?.dispose();
  }
}

Future<ui.Image> _bytesToImage(Uint8List bytes) async {
  ui.Codec codec = await ui.instantiateImageCodec(bytes);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}
