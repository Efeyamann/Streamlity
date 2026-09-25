import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/services/favorites_store.dart';

Channel _ch(String name, {String? group, String? id}) =>
    Channel(name: name, url: 'http://x/$name', group: group, id: id);

void main() {
  group('ayraç satırları', () {
    test('sağlayıcı başlıklarını tanır', () {
      expect(_ch('####### NEWS #######').separatorLabel, 'NEWS');
      expect(_ch('## NOW TV SPORT ᴴᴰ/ᴿᴬᵂ ##').separatorLabel,
          'NOW TV SPORT ᴴᴰ/ᴿᴬᵂ');
      expect(_ch('#### PRIME ᴿᴬᵂ ⁶⁰ᶠᵖˢ #####').separatorLabel, 'PRIME ᴿᴬᵂ ⁶⁰ᶠᵖˢ');
      expect(_ch('===== SPOR =====').separatorLabel, 'SPOR');
      expect(_ch('━━ Belgesel ━━').separatorLabel, 'Belgesel');
      expect(_ch('########').isSeparator, isTrue);
    });

    test('gerçek kanalları ayraç saymaz', () {
      for (final name in [
        'UK: SKY NEWS HD ◉',
        '#1 Music',
        'TRT 1 ##',
        '## Yarım',
        'A - B - C',
      ]) {
        expect(_ch(name).isSeparator, isFalse, reason: name);
      }
    });

    test('kanal sayısına ayraçlar girmez', () {
      final playlist = Playlist(channels: [
        _ch('### A ###'),
        _ch('Kanal 1'),
        _ch('Kanal 2'),
      ]);
      expect(playlist.channelCount, 2);
    });
  });

  test('kanal anahtarı kalıcı kimliği, yoksa grup ve adı kullanır', () {
    expect(_ch('A', group: 'G', id: '42').key, '42');
    expect(_ch('A', group: 'G').key, isNot(_ch('A', group: 'H').key));
    expect(_ch('A', group: 'G').key, _ch('A', group: 'G').key);
  });

  group('FavoritesStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('streamlity_fav'));
    tearDown(() => dir.deleteSync(recursive: true));

    final xtream =
        XtreamSource(server: 'http://s.tv', username: 'u', password: 'p');
    const m3u = M3uSource('http://liste.tv/get.php?username=gizli&password=gizli');

    test('kaynak başına saklar ve yeniden okur', () async {
      final store = FavoritesStore(directory: () async => dir);
      await store.write(xtream, {'1', '2'});
      await store.write(m3u, {'G\u0000A'});

      final fresh = FavoritesStore(directory: () async => dir);
      expect(await fresh.read(xtream), {'1', '2'});
      expect(await fresh.read(m3u), {'G\u0000A'});
    });

    test('şifre değişince favoriler korunur', () async {
      final store = FavoritesStore(directory: () async => dir);
      await store.write(xtream, {'1'});
      final changed =
          XtreamSource(server: 'http://s.tv', username: 'u', password: 'yeni');
      expect(await store.read(changed), {'1'});
    });

    test('dosyaya kimlik bilgisi yazmaz', () async {
      final store = FavoritesStore(directory: () async => dir);
      await store.write(m3u, {'x'});
      final content =
          File('${dir.path}${Platform.pathSeparator}favorites.json')
              .readAsStringSync();
      expect(content, isNot(contains('gizli')));
    });

    test('bozuk dosyada boş başlar', () async {
      File('${dir.path}${Platform.pathSeparator}favorites.json')
          .writeAsStringSync('{bozuk');
      final store = FavoritesStore(directory: () async => dir);
      expect(await store.read(xtream), isEmpty);
    });
  });

  test('arama anahtarı Türkçe İ/I farkını yok sayar', () {
    expect(searchKey('TR| TÜRKİYE 4K').contains(searchKey('türkiye')), isTrue);
    expect(searchKey('TR| FIMLER 4K').contains(searchKey('fimler')), isTrue);
    expect(searchKey('Kızılcık').contains(searchKey('KIZILCIK')), isTrue);
    expect(searchKey('Spor'), 'spor');
  });
}
