import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/services/player_setup.dart';
import 'package:streamlity/services/settings_store.dart';

void main() {
  group('VSR büyütme oranı', () {
    double? scale(int video, double display) => VideoSuperResolution.scaleFor(
        videoHeight: video, displayHeight: display);

    test('görüntü monitörün yüksekliğine büyütülür', () {
      expect(scale(1080, 2160), 2);
      expect(scale(720, 1080), 1.5);
      expect(scale(720, 1440), 2);
    });

    test('monitörden büyük ya da ona yakın görüntüde oran 1', () {
      expect(scale(1080, 1080), 1);
      expect(scale(2160, 1080), 1);
      expect(scale(1000, 1080), 1);
    });

    test('oran 4 ile sınırlı ve onda bire yuvarlanır', () {
      expect(scale(240, 2160), 4);
      expect(scale(576, 1080), 1.9);
    });

    test('bilinmeyen boyutta filtre yok', () {
      expect(scale(0, 1080), isNull);
      expect(scale(1080, 0), isNull);
    });
  });

  test('VSR ayarı saklanır, kapalıyken dosyaya yazılmaz', () async {
    final dir = Directory.systemTemp.createTempSync('vsr_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = SettingsStore(directory: () async => dir);

    expect(await store.readRtxVsr(), isFalse);
    await store.writeRtxVsr(true);
    expect(await store.readRtxVsr(), isTrue);
    await store.writeRtxVsr(false);
    expect(await store.readRtxVsr(), isFalse);
    expect(
        File('${dir.path}${Platform.pathSeparator}settings.json')
            .readAsStringSync(),
        isNot(contains('rtxVsr')));
  });
}
