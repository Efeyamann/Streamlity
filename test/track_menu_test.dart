import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/screens/track_menu.dart';

void main() {
  test('parça adı dil ve başlıktan kurulur', () {
    expect(trackLabel('1', null, 'tur'), 'Türkçe');
    expect(trackLabel('2', 'Stereo', 'eng'), 'İngilizce (Stereo)');
    expect(trackLabel('3', 'Türkçe', 'tur'), 'Türkçe');
    expect(trackLabel('4', null, 'xho'), 'XHO');
    expect(trackLabel('7', 'Polish', 'pol'), 'Lehçe (Polish)');
    expect(trackLabel('5', 'Orijinal', 'und'), 'Orijinal');
    expect(trackLabel('6', ' ', null), 'Parça 6');
  });
}
