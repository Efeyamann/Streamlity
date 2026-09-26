import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/services/favorites_store.dart';
import 'package:streamlity/services/parental_lock.dart';
import 'package:streamlity/services/settings_store.dart';

void main() {
  late Directory dir;
  Future<Directory> directory() async => dir;
  final source =
      XtreamSource(server: 'http://s.tv', username: 'u', password: 'p');

  setUp(() => dir = Directory.systemTemp.createTempSync('pin_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('PIN tuzlu özetle saklanır, açık yazılmaz', () async {
    final lock = ParentalLock(directory: directory);
    await lock.setPin('1234');
    final text =
        File('${dir.path}${Platform.pathSeparator}settings.json')
            .readAsStringSync();
    expect(text, isNot(contains('1234')));

    final saved = await SettingsStore(directory: directory).readPin();
    expect(saved, isNotNull);
    expect(ParentalLock.hashPin('1234', salt: saved!.salt).hash, saved.hash);
    // Aynı PIN farklı tuzla farklı özet verir.
    expect(ParentalLock.hashPin('1234').hash, isNot(saved.hash));
  });

  test('yeniden açılışta PIN okunur, kilitler kapalı başlar', () async {
    await ParentalLock(directory: directory).setPin('4321');
    final lock = ParentalLock(directory: directory);
    expect(lock.hasPin, isFalse);
    await lock.load();
    expect(lock.hasPin, isTrue);
    expect(lock.active, isTrue);
    expect(lock.check('0000'), isFalse);
    expect(lock.check('4321'), isTrue);
    // check kilidi açmaz.
    expect(lock.active, isTrue);
  });

  test('doğru PIN oturum boyunca açar, lock yeniden kapatır', () async {
    final lock = ParentalLock(directory: directory);
    await lock.setPin('1111');
    expect(lock.unlock('2222'), isFalse);
    expect(lock.active, isTrue);
    expect(lock.unlock('1111'), isTrue);
    expect(lock.active, isFalse);
    lock.lock();
    expect(lock.active, isTrue);
  });

  test('PIN kaldırılınca tüm kategori kilitleri silinir', () async {
    final locks = FavoritesStore.lockedCategories(directory: directory);
    await locks.writeList(source, ['l:Yetişkin', 'm:7']);
    final lock = ParentalLock(directory: directory);
    await lock.setPin('1234');
    await lock.removePin();
    expect(lock.hasPin, isFalse);
    expect(lock.active, isFalse);
    expect(await SettingsStore(directory: directory).readPin(), isNull);
    // Başka bir örneğin önbelleği de silineni görür.
    expect(await locks.readList(source), isEmpty);
  });

  test('PIN dil ayarını silmez', () async {
    final settings = SettingsStore(directory: directory);
    await settings.writeLanguage('de');
    await ParentalLock(directory: directory).setPin('1234');
    expect(await settings.readLanguage(), 'de');
  });
}
