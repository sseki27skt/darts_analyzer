// デフォルト（unsupported）をエクスポートしつつ、
// 環境に応じて native.dart か web.dart に差し替える
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.html) 'web.dart';