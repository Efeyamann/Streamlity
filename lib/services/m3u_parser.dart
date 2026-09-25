import 'dart:convert';

import '../models/playlist.dart';

final _attributePattern = RegExp(r'([\w-]+)="([^"]*)"');

/// M3U / M3U8 (extended) içeriğini ayrıştırır.
///
/// Bilinmeyen `#` satırları yok sayılır. `#EXTINF` olmadan gelen URL'ler de
/// kanal olarak eklenir; adları URL'nin kendisi olur.
Playlist parseM3u(String content) {
  final channels = <Channel>[];
  String? epgUrl;

  Map<String, String>? attributes;
  String? title;
  String? extGroup;

  for (final raw in LineSplitter.split(content)) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#EXTM3U')) {
      final header = _attributes(line);
      epgUrl = _nonEmpty(header['url-tvg']) ?? _nonEmpty(header['x-tvg-url']);
    } else if (line.startsWith('#EXTINF:')) {
      attributes = _attributes(line);
      title = _title(line);
      extGroup = null;
    } else if (line.startsWith('#EXTGRP:')) {
      extGroup = line.substring('#EXTGRP:'.length).trim();
    } else if (!line.startsWith('#')) {
      final a = attributes ?? const {};
      channels.add(Channel(
        name: _nonEmpty(title) ?? _nonEmpty(a['tvg-name']) ?? line,
        url: line,
        group: _nonEmpty(a['group-title']) ?? _nonEmpty(extGroup),
        logo: _nonEmpty(a['tvg-logo']),
        tvgId: _nonEmpty(a['tvg-id']),
      ));
      attributes = null;
      title = null;
      extGroup = null;
    }
  }

  return Playlist(channels: channels, epgUrl: epgUrl);
}

Map<String, String> _attributes(String line) => {
      for (final m in _attributePattern.allMatches(line))
        m.group(1)!.toLowerCase(): m.group(2)!,
    };

/// Tırnak dışındaki ilk virgülden sonrası kanal adıdır; öznitelik
/// değerlerinin içindeki virgüller atlanır.
String? _title(String line) {
  var inQuotes = false;
  for (var i = '#EXTINF:'.length; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (c == ',' && !inQuotes) {
      return line.substring(i + 1).trim();
    }
  }
  return null;
}

String? _nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
