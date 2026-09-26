import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Arayüz dili: dil kodu ya da null (sistem diline uy). Değişince uygulama
/// yeniden çizilir ve seçim [SettingsStore] ile saklanır.
final appLanguage = ValueNotifier<String?>(null);

/// PIN'in saklanan hali: rastgele tuz ve sha256(tuz + PIN), ikisi de
/// onaltılık.
typedef PinHash = ({String salt, String hash});

/// Uygulama ayarları (`settings.json`): dil ve ebeveyn denetimi PIN'i.
class SettingsStore {
  SettingsStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async => File(
      '${(await _directory()).path}${Platform.pathSeparator}settings.json');

  Future<Map<String, dynamic>> _read() async {
    try {
      final json = jsonDecode(await (await _file()).readAsString());
      return json is Map<String, dynamic> ? json : {};
    } on Exception {
      return {};
    }
  }

  Future<String?> readLanguage() async {
    final code = (await _read())['language'];
    return code is String && code.isNotEmpty ? code : null;
  }

  Future<void> writeLanguage(String? code) => _update((all) {
        if (code == null) {
          all.remove('language');
        } else {
          all['language'] = code;
        }
      });

  Future<PinHash?> readPin() async {
    final pin = (await _read())['pin'];
    if (pin is! Map) return null;
    final salt = pin['salt'], hash = pin['hash'];
    return salt is String && hash is String ? (salt: salt, hash: hash) : null;
  }

  Future<void> writePin(PinHash? pin) => _update((all) {
        if (pin == null) {
          all.remove('pin');
        } else {
          all['pin'] = {'salt': pin.salt, 'hash': pin.hash};
        }
      });

  Future<void> _update(void Function(Map<String, dynamic> all) change) async {
    try {
      final all = await _read();
      change(all);
      final file = await _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(all), flush: true);
    } on Exception catch (e) {
      debugPrint('Ayarlar kaydedilemedi: $e');
    }
  }
}
