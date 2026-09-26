import 'package:flutter/foundation.dart';

/// Uygulama genelinde sessizlik: canlı TV kareleri ve film/dizi oynatıcısı
/// aynı durumu paylaşır, ekran değişince ses kendiliğinden açılmaz.
final appMuted = ValueNotifier<bool>(false);
