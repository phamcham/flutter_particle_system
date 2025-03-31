import 'dart:ui' as ui;

import 'package:flutter/services.dart';

final packageBundle = _PackageAssetBundle('flutter_particle_system');

class _PackageAssetBundle extends PlatformAssetBundle {
  final String packageName;

  _PackageAssetBundle(this.packageName);

  @override
  Future<ByteData> load(String key) {
    return super.load(_packageKey(key));
  }

  @override
  Future<ui.ImmutableBuffer> loadBuffer(String key) async {
    return super.loadBuffer(_packageKey(key));
  }

  String _packageKey(String key) => 'packages/$packageName/$key';
}
