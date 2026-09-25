import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/services/stall_watchdog.dart';

void main() {
  late DateTime now;
  late List<int> retries;
  late int giveUps;
  late StallWatchdog dog;

  void advance(int seconds, {bool playing = true}) {
    now = now.add(Duration(seconds: seconds));
    dog.check(playing: playing);
  }

  setUp(() {
    now = DateTime(2026, 9, 25, 18);
    retries = [];
    giveUps = 0;
    dog = StallWatchdog(
      onRetry: retries.add,
      onGiveUp: () => giveUps++,
      timeout: const Duration(seconds: 10),
      maxRetries: 2,
      clock: () => now,
    )..start();
  });

  test('akış ilerledikçe müdahale etmez', () {
    for (var i = 0; i < 10; i++) {
      advance(5);
      dog.progress();
    }
    expect(retries, isEmpty);
    expect(dog.status, StallStatus.ok);
  });

  test('ilerlemezse yeniden dener, sonra vazgeçer', () {
    advance(9);
    expect(retries, isEmpty);
    advance(1);
    expect(retries, [1]);
    expect(dog.status, StallStatus.reconnecting);
    advance(10);
    expect(retries, [1, 2]);
    expect(dog.attempt, 2);
    advance(10);
    expect(retries, [1, 2]);
    expect(dog.status, StallStatus.failed);
    expect(giveUps, 1);
    advance(30);
    expect(retries, [1, 2], reason: 'vazgeçtikten sonra durur');
    expect(giveUps, 1);
  });

  test('yeniden bağlanınca sayaç sıfırlanır', () {
    advance(10);
    expect(retries, [1]);
    dog.progress();
    expect(dog.status, StallStatus.ok);
    expect(dog.attempt, 0);
    advance(10);
    expect(retries, [1, 1]);
  });

  test('duraklatılmışken süre saymaz', () {
    advance(60, playing: false);
    advance(9);
    expect(retries, isEmpty);
  });

  test('durdurulunca ve yeni kanalda baştan başlar', () {
    advance(10);
    advance(10);
    advance(10);
    expect(dog.status, StallStatus.failed);
    dog.start();
    expect(dog.status, StallStatus.ok);
    advance(10);
    expect(retries, [1, 2, 1]);
    dog.stop();
    advance(60);
    expect(retries, [1, 2, 1]);
  });
}
