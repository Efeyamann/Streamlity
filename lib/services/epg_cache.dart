import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// İndirilen XMLTV dosyalarını sıkıştırılmış olarak diskte tutar.
///
/// Her adres ayrı dosyadadır; dosya adı adresin özetidir (adreste kimlik
/// bilgisi olabilir). Kayıt zamanı dosyanın değişiklik zamanıdır. Sınıf
/// yalnız `dart:io` kullanır; isolate içinde çalışabilir.
class EpgCache {
  EpgCache(this.directory, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final String directory;
  final DateTime Function() _clock;

  File _file(String url) => File('$directory${Platform.pathSeparator}'
      '${sha1.convert(utf8.encode(url))}.xml.gz');

  /// Kayıtlı içerik ve yaşı; kayıt yoksa ya da okunamıyorsa null.
  Future<({List<int> xml, Duration age})?> read(String url) async {
    final file = _file(url);
    try {
      final modified = await file.lastModified();
      final xml = gzip.decode(await file.readAsBytes());
      return (xml: xml, age: _clock().difference(modified));
    } on Exception {
      return null;
    }
  }

  /// [bytes] ham ya da gzip'li XMLTV olabilir; diske gzip'li yazılır.
  Future<void> write(String url, List<int> bytes) async {
    await Directory(directory).create(recursive: true);
    final file = _file(url);
    // Yarım kalan yazma kaydı bozmasın diye önce geçici dosyaya yaz.
    final temp = File('${file.path}.tmp');
    await temp.writeAsBytes(isGzip(bytes) ? bytes : gzip.encode(bytes),
        flush: true);
    await temp.rename(file.path);
  }

  /// [maxAge]'den eski kayıtları siler (ör. artık kullanılmayan kaynaklar).
  Future<void> prune(Duration maxAge) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return;
    final now = _clock();
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      try {
        if (now.difference(await entity.lastModified()) > maxAge) {
          await entity.delete();
        }
      } on FileSystemException {
        // Başka bir süreç kullanıyor olabilir; bir dahakine.
      }
    }
  }
}

bool isGzip(List<int> bytes) =>
    bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
