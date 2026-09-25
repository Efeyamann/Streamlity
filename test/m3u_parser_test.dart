import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/services/m3u_parser.dart';

void main() {
  test('öznitelikleri, adı ve grubu okur', () {
    final playlist = parseM3u('''
﻿#EXTM3U url-tvg="http://epg.example/guide.xml"
#EXTINF:-1 tvg-id="trt1.tr" tvg-logo="http://logo/trt1.png" group-title="Ulusal, Genel",TRT 1
http://stream/trt1.m3u8

#EXTINF:-1,Haber Kanalı
#EXTGRP:Haber
#EXTVLCOPT:http-user-agent=Test
http://stream/haber.ts
''');

    expect(playlist.epgUrl, 'http://epg.example/guide.xml');
    expect(playlist.channels, hasLength(2));

    final trt = playlist.channels[0];
    expect(trt.name, 'TRT 1');
    expect(trt.url, 'http://stream/trt1.m3u8');
    expect(trt.group, 'Ulusal, Genel');
    expect(trt.logo, 'http://logo/trt1.png');
    expect(trt.tvgId, 'trt1.tr');

    final haber = playlist.channels[1];
    expect(haber.name, 'Haber Kanalı');
    expect(haber.group, 'Haber');
    expect(haber.logo, isNull);

    expect(playlist.groups, ['Ulusal, Genel', 'Haber']);
  });

  test('EXTINF olmayan URL ve boş adı toparlar', () {
    final playlist = parseM3u('''
#EXTM3U
http://stream/plain.ts
#EXTINF:-1 tvg-name="Yedek Ad",
http://stream/named.ts
''');

    expect(playlist.channels.map((c) => c.name),
        ['http://stream/plain.ts', 'Yedek Ad']);
    expect(playlist.groups, ['Grupsuz']);
  });
}
