import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/services/xtream_client.dart';

void main() {
  group('XtreamSource', () {
    test('sunucu adresini normalleştirir', () {
      expect(XtreamSource.normalizeServer('sunucu.tv:8080/'),
          'http://sunucu.tv:8080');
      expect(XtreamSource.normalizeServer(' https://sunucu.tv/player_api.php '),
          'https://sunucu.tv');
    });

    test('sağlayıcı linkinden giriş bilgilerini çıkarır', () {
      final source = XtreamSource.tryParseLink(
          'http://sunucu.tv:8080/get.php?username=ali&password=p%40ss&type=m3u_plus&output=ts');
      expect(source, isNotNull);
      expect(source!.server, 'http://sunucu.tv:8080');
      expect(source.username, 'ali');
      expect(source.password, 'p@ss');

      expect(XtreamSource.tryParseLink('http://sunucu.tv:8080'), isNull);
      expect(XtreamSource.tryParseLink('sunucu.tv'), isNull);
    });

    test('JSON üzerinden geri yüklenir', () {
      final source = XtreamSource(
          server: 'http://s.tv', username: 'u', password: 'p');
      final restored = PlaylistSource.fromJson(source.toJson());
      expect(restored, isA<XtreamSource>());
      expect((restored as XtreamSource).password, 'p');
    });
  });

  test('kanalları kategori sırasıyla ve doğru URL ile kurar', () {
    final playlist = buildXtreamPlaylist(
      source: XtreamSource(
          server: 'http://s.tv:80', username: 'u/1', password: 'p'),
      categories: [
        {'category_id': '2', 'category_name': 'Spor'},
        {'category_id': '1', 'category_name': 'Haber'},
      ],
      streams: [
        {'stream_id': 10, 'name': 'Haber 1', 'category_id': '1'},
        {
          'stream_id': '20',
          'name': 'Spor 1',
          'category_id': '2',
          'stream_icon': 'http://logo',
          'epg_channel_id': 'spor1',
        },
        {'stream_id': 30, 'name': '', 'category_id': '99'},
        {'name': 'Kimliksiz'},
      ],
      extension: 'ts',
    );

    expect(playlist.channels.map((c) => c.name),
        ['Spor 1', 'Haber 1', 'Kanal 30']);
    expect(playlist.groups, ['Spor', 'Haber', 'Grupsuz']);

    final spor = playlist.channels.first;
    // Varsayılan port (80) Uri tarafından atılır.
    expect(spor.url, 'http://s.tv/live/u%2F1/p/20.ts');
    expect(spor.logo, 'http://logo');
    expect(spor.tvgId, 'spor1');
  });
}
