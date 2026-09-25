import '../models/epg.dart';

/// XMLTV içeriğini ayrıştırır.
///
/// Sağlayıcı dosyaları 50–100 MB olabildiği için tam bir XML ağacı kurulmaz;
/// yalnız `<programme>` öğeleri sırayla taranır. [only] verilirse yalnız bu
/// (küçük harfli) kanal kimliklerinin programları tutulur.
Epg parseXmltv(String xml, {Set<String>? only}) {
  final byChannel = <String, List<_Draft>>{};
  var i = 0;
  while (true) {
    final open = xml.indexOf('<programme', i);
    if (open < 0) break;
    final tagEnd = xml.indexOf('>', open);
    if (tagEnd < 0) break;
    if (xml.codeUnitAt(tagEnd - 1) == 0x2F /* / */) {
      i = tagEnd + 1;
      continue;
    }
    final close = xml.indexOf('</programme>', tagEnd);
    if (close < 0) break;
    i = close + '</programme>'.length;

    final tag = xml.substring(open, tagEnd);
    final channel = _attribute(tag, 'channel')?.trim().toLowerCase();
    if (channel == null || channel.isEmpty) continue;
    if (only != null && !only.contains(channel)) continue;
    final start = parseXmltvTime(_attribute(tag, 'start'));
    if (start == null) continue;

    final body = xml.substring(tagEnd + 1, close);
    final title = _element(body, 'title');
    if (title == null || title.isEmpty) continue;
    byChannel.putIfAbsent(channel, () => []).add(_Draft(
          start: start,
          stop: parseXmltvTime(_attribute(tag, 'stop')),
          title: title,
          description: _element(body, 'desc'),
        ));
  }

  return Epg({
    for (final MapEntry(:key, :value) in byChannel.entries)
      key: _finish(value),
  });
}

class _Draft {
  _Draft({
    required this.start,
    required this.stop,
    required this.title,
    required this.description,
  });

  final DateTime start;
  final DateTime? stop;
  final String title;
  final String? description;
}

/// Sıralar; bitişi olmayan programı bir sonrakinin başlangıcında bitirir.
/// Aynı kanal farklı harf büyüklüğüyle iki kez listelenebildiği için aynı
/// anda başlayan kopyalar atılır.
List<Programme> _finish(List<_Draft> all) {
  all.sort((a, b) => a.start.compareTo(b.start));
  final drafts = <_Draft>[
    for (var i = 0; i < all.length; i++)
      if (i == 0 || all[i].start != all[i - 1].start) all[i],
  ];
  return [
    for (var i = 0; i < drafts.length; i++)
      Programme(
        start: drafts[i].start,
        stop: drafts[i].stop ??
            (i + 1 < drafts.length
                ? drafts[i + 1].start
                : drafts[i].start.add(const Duration(hours: 1))),
        title: drafts[i].title,
        description: drafts[i].description,
      ),
  ];
}

/// `20260924180000 +0200` biçimindeki zamanı UTC'ye çevirir. Saniye ve
/// saat dilimi isteğe bağlı; dilim yoksa UTC varsayılır.
DateTime? parseXmltvTime(String? value) {
  if (value == null) return null;
  final s = value.trim();
  if (s.length < 12) return null;
  int? n(int from, int to) =>
      to <= s.length ? int.tryParse(s.substring(from, to)) : null;
  final year = n(0, 4), month = n(4, 6), day = n(6, 8);
  final hour = n(8, 10), minute = n(10, 12);
  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }
  final second =
      s.length >= 14 ? int.tryParse(s.substring(12, 14)) ?? 0 : 0;
  var time = DateTime.utc(year, month, day, hour, minute, second);

  final zone = RegExp(r'([+-])(\d{2}):?(\d{2})$').firstMatch(s);
  if (zone != null) {
    final offset = Duration(
      hours: int.parse(zone.group(2)!),
      minutes: int.parse(zone.group(3)!),
    );
    time = zone.group(1) == '+' ? time.subtract(offset) : time.add(offset);
  }
  return time;
}

String? _attribute(String tag, String name) {
  var from = 0;
  while (true) {
    final at = tag.indexOf(name, from);
    if (at < 0) return null;
    from = at + name.length;
    // `start` ararken `xstart` gibi bir önekle eşleşmeyi önle.
    if (at > 0 && tag.codeUnitAt(at - 1) > 0x20) continue;
    var j = from;
    while (j < tag.length && tag.codeUnitAt(j) == 0x20) {
      j++;
    }
    if (j >= tag.length || tag[j] != '=') continue;
    j++;
    while (j < tag.length && tag.codeUnitAt(j) == 0x20) {
      j++;
    }
    if (j >= tag.length) return null;
    final quote = tag[j];
    if (quote != '"' && quote != "'") continue;
    final end = tag.indexOf(quote, j + 1);
    if (end < 0) return null;
    return _decode(tag.substring(j + 1, end));
  }
}

/// [body] içindeki ilk `<name ...>metin</name>` öğesinin metni.
String? _element(String body, String name) {
  final open = body.indexOf('<$name');
  if (open < 0) return null;
  final after = open + name.length + 1;
  if (after < body.length && !' >/'.contains(body[after])) return null;
  final tagEnd = body.indexOf('>', open);
  if (tagEnd < 0 || body.codeUnitAt(tagEnd - 1) == 0x2F) return null;
  final close = body.indexOf('</$name>', tagEnd);
  if (close < 0) return null;
  var text = body.substring(tagEnd + 1, close).trim();
  if (text.startsWith('<![CDATA[') && text.endsWith(']]>')) {
    return text.substring(9, text.length - 3).trim();
  }
  text = _decode(text).trim();
  return text.isEmpty ? null : text;
}

final _entity = RegExp(r'&(#x[0-9a-fA-F]+|#\d+|amp|lt|gt|quot|apos);');

String _decode(String s) {
  if (!s.contains('&')) return s;
  return s.replaceAllMapped(_entity, (m) {
    final e = m.group(1)!;
    return switch (e) {
      'amp' => '&',
      'lt' => '<',
      'gt' => '>',
      'quot' => '"',
      'apos' => "'",
      _ when e.startsWith('#x') =>
        String.fromCharCode(int.parse(e.substring(2), radix: 16)),
      _ => String.fromCharCode(int.parse(e.substring(1))),
    };
  });
}
