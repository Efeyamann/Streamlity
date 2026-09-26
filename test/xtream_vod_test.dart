import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/models/vod.dart';
import 'package:streamlity/services/xtream_client.dart';
import 'package:streamlity/services/xtream_vod.dart';

void main() {
  final source =
      XtreamSource(server: 'http://s.tv:8080', username: 'u', password: 'p@1');

  test('film kataloğu ve adresi', () {
    final catalog = parseVodCatalog(
      VodKind.movie,
      [
        {'category_id': '5', 'category_name': 'Aksiyon'},
      ],
      [
        {
          'stream_id': 42,
          'name': ' Film A ',
          'category_id': '5',
          'stream_icon': 'http://img/a.jpg',
          'rating': '7.4',
          'container_extension': 'mkv',
          'added': '1700000000',
        },
        {'name': 'kimliksiz'},
        {'stream_id': 43, 'name': '', 'rating': '', 'year': '2021'},
      ],
    );
    expect(catalog.categories.single.name, 'Aksiyon');
    expect(catalog.items.length, 2);
    final a = catalog.items.first;
    expect(a.name, 'Film A');
    expect(a.rating, 7.4);
    expect(a.key, 'm:42');
    expect(movieUrl(source, a), 'http://s.tv:8080/movie/u/p%401/42.mkv');
    expect(catalog.items.last.name, 'Film 43');
    expect(catalog.items.last.year, 2021);
    expect(catalog.items.last.rating, isNull);
  });

  test('dizi bölümleri sezonlara ayrılır ve sıralanır', () {
    final details = parseSeriesDetails({
      'info': {'plot': 'Konu', 'genre': 'Dram', 'backdrop_path': ['http://b']},
      'episodes': {
        '2': [
          {'id': '201', 'episode_num': 1, 'season': 2, 'title': 'S2B1',
            'container_extension': 'mp4'},
        ],
        '1': [
          {'id': '102', 'episode_num': '2', 'season': '1', 'title': 'S1B2',
            'container_extension': 'mkv',
            'info': {'duration_secs': 2700, 'plot': 'İkinci'}},
          {'id': '101', 'episode_num': '1', 'season': '1', 'title': 'S1B1',
            'container_extension': 'mkv', 'info': {'duration': '00:44:10'}},
        ],
      },
    });
    expect(details.info.plot, 'Konu');
    expect(details.info.backdrop, 'http://b');
    expect(details.seasons.keys, [1, 2]);
    expect(details.seasons[1]!.map((e) => e.title), ['S1B1', 'S1B2']);
    expect(details.seasons[1]!.first.duration,
        const Duration(minutes: 44, seconds: 10));
    expect(details.seasons[1]!.last.duration, const Duration(minutes: 45));
    expect(episodeUrl(source, details.seasons[2]!.single),
        'http://s.tv:8080/series/u/p%401/201.mp4');
  });

  test('geçmiş yayın adresi sunucu saatiyle yazılır', () {
    final url = catchupUrl(
      source,
      streamId: '9',
      start: DateTime.utc(2026, 9, 25, 17, 45),
      duration: const Duration(minutes: 59, seconds: 30),
      serverOffset: const Duration(hours: 3),
    );
    expect(url, 'http://s.tv:8080/timeshift/u/p%401/60/2026-09-25:20-45/9.ts');
  });

  test('sunucu saat farkı server_info\'dan hesaplanır', () {
    final utc = DateTime.utc(2026, 9, 25, 17, 30, 12);
    expect(
      serverUtcOffset({
        'time_now': '2026-09-25 20:30:10',
        'timestamp_now': utc.millisecondsSinceEpoch ~/ 1000,
      }),
      const Duration(hours: 3),
    );
    expect(serverUtcOffset({'time_now': 'bozuk'}), isNull);
    expect(serverUtcOffset(null), isNull);
  });

  test('canlı kanalda arşiv günü okunur', () {
    final playlist = buildXtreamPlaylist(
      source: source,
      categories: const [],
      streams: [
        {'stream_id': 1, 'name': 'A', 'tv_archive': 1,
          'tv_archive_duration': '7'},
        {'stream_id': 2, 'name': 'B', 'tv_archive': 0,
          'tv_archive_duration': '7'},
      ],
      extension: 'ts',
    );
    expect(playlist.channels.map((c) => c.archiveDays), [7, 0]);
  });
}
