import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/l10n/l10n.dart';
import 'package:streamlity/screens/track_menu.dart';

void main() {
  test('parça adı dilin kendi adından ve başlıktan kurulur', () {
    final tr = lookupAppLocalizations(const Locale('tr'));
    expect(trackLabel(tr, '1', null, 'tur'), 'Türkçe');
    expect(trackLabel(tr, '2', 'Stereo', 'eng'), 'English (Stereo)');
    expect(trackLabel(tr, '3', 'Türkçe', 'tur'), 'Türkçe');
    expect(trackLabel(tr, '3', 'english', 'en'), 'English');
    expect(trackLabel(tr, '4', null, 'xho'), 'XHO');
    expect(trackLabel(tr, '7', 'Polish', 'pol'), 'Polski (Polish)');
    expect(trackLabel(tr, '5', 'Orijinal', 'und'), 'Orijinal');
    expect(trackLabel(tr, '6', ' ', null), 'Parça 6');
    final en = lookupAppLocalizations(const Locale('en'));
    expect(trackLabel(en, '6', null, null), 'Track 6');
  });
}
