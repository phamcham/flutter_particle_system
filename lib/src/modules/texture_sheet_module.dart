import 'dart:math';

import '../../flutter_particle_system.dart';

class TextureSheetModule {
  /// làm mịn ảnh, tắt nếu dùng các ảnh siêu nhỏ mà sắc nét
  bool isAntiAlias;
  List<TextureLoader> textureSheet;

  TextureSheetModule({required this.isAntiAlias, required this.textureSheet});

  TextureLoader random([Random? rnd]) {
    assert(textureSheet.isNotEmpty);
    return textureSheet[(rnd ?? Random()).nextInt(textureSheet.length)];
  }
}
