import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Arayüz dili: dil kodu ya da null (sistem diline uy). Değişince uygulama
/// yeniden çizilir ve seçim [SettingsStore] ile saklanır.
final appLanguage = ValueNotifier<String?>(null);

/// Uygulama ayarları (`settings.json`). Şimdilik yalnız dil.
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

  Future<void> writeLanguage(String? code) async {
    try {
      final all = await _read();
      if (code == null) {
        all.remove('language');
      } else {
        all['language'] = code;
      }
      final file = await _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(all), flush: true);
    } on Exception catch (e) {
      debugPrint('Ayarlar kaydedilemedi: $e');
    }
  }
}
