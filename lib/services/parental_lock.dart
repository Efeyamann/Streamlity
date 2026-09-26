import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'favorites_store.dart';
import 'settings_store.dart';

/// PIN'in hane sayısı.
const pinLength = 4;

/// Ebeveyn denetimi: PIN ve bu oturumda kilitlerin açılıp açılmadığı.
///
/// PIN açık yazılmaz; `settings.json`'a tuzlu sha256 özeti yazılır. Kilitli
/// bir kategori PIN'le açılınca uygulama kapanana kadar (ya da [lock]
/// çağrılana kadar) tüm kilitli kategoriler açık kalır.
class ParentalLock extends ChangeNotifier {
  ParentalLock({Future<Directory> Function()? directory})
      : _settings = SettingsStore(directory: directory),
        _locks = FavoritesStore.lockedCategories(directory: directory);

  final SettingsStore _settings;
  final FavoritesStore _locks;
  static final _random = Random.secure();

  PinHash? _pin;
  bool _unlocked = false;

  bool get hasPin => _pin != null;
  bool get unlocked => _unlocked;

  /// Kilitli kategoriler şu an kapalı mı: PIN var ve bu oturumda açılmadı.
  bool get active => hasPin && !_unlocked;

  Future<void> load() async {
    _pin = await _settings.readPin();
    notifyListeners();
  }

  static PinHash hashPin(String pin, {String? salt}) {
    salt ??= [
      for (var i = 0; i < 16; i++)
        _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    return (
      salt: salt,
      hash: sha256.convert(utf8.encode('$salt$pin')).toString(),
    );
  }

  /// PIN doğru mu; kilitlerin durumunu değiştirmez.
  bool check(String pin) {
    final saved = _pin;
    return saved != null && hashPin(pin, salt: saved.salt).hash == saved.hash;
  }

  /// PIN doğruysa kilitleri bu oturum için açar.
  bool unlock(String pin) {
    if (!check(pin)) return false;
    _unlocked = true;
    notifyListeners();
    return true;
  }

  /// Açılan kilitleri yeniden kapatır.
  void lock() {
    if (!_unlocked) return;
    _unlocked = false;
    notifyListeners();
  }

  /// Yeni PIN'i kaydeder; kilitler kapalı başlar.
  Future<void> setPin(String pin) async {
    _pin = hashPin(pin);
    _unlocked = false;
    notifyListeners();
    await _settings.writePin(_pin);
  }

  /// PIN'i ve tüm listelerdeki kategori kilitlerini siler.
  Future<void> removePin() async {
    _pin = null;
    _unlocked = false;
    notifyListeners();
    await _settings.writePin(null);
    await _locks.clear();
  }
}

final parentalLock = ParentalLock();
