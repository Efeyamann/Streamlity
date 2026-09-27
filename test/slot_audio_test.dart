import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/services/stream_slot.dart';

void main() {
  test('karenin sesi kapalıyken ya da uygulama sessizken düzey sıfır', () {
    final audio = SlotAudio()..volume = 60;
    expect(audio.output, 60);
    audio.audible = false;
    expect(audio.output, 0);
    audio
      ..audible = true
      ..muted = true;
    expect(audio.output, 0);
    // Kapalıyken düzey unutulmaz.
    audio.muted = false;
    expect(audio.output, 60);
  });

  test('ses yalnız tek karede açıkken seçimi izler', () {
    expect(audioFollowsSelection([true, false]), isTrue);
    expect(audioFollowsSelection([true, true]), isFalse);
    expect(audioFollowsSelection([false, false, false]), isFalse);
    expect(audioFollowsSelection(const []), isFalse);
  });
}
