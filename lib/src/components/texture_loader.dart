import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../package_bundle.dart';

final _softCircleTexturePath = 'assets/particles/particle_soft_circle.png';
final _squareTexturePath = 'assets/particles/particle_square.jpg';

TextureLoader createSoftCircleTexture() =>
    _createTexture(_softCircleTexturePath);

TextureLoader createSquareTexture() => _createTexture(_squareTexturePath);

TextureLoader _createTexture(String path) => TextureLoader(
  loadBytes: () async {
    final byteData = await packageBundle.load(path);
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
