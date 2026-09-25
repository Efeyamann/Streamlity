import 'package:flutter/foundation.dart';

enum StallStatus { ok, reconnecting, failed }

/// Canlı yayının durduğunu (açılışta hiç başlamaması ya da ortada donması)
/// oynatma konumunun ilerlememesinden anlar ve yeniden bağlanmayı tetikler.
///
/// Zamanlayıcı dışarıdan [check] çağırarak sürülür; böylece testte saat
/// enjekte edilebilir.
class StallWatchdog extends ChangeNotifier {
  StallWatchdog({
    required this.onRetry,
    this.onGiveUp,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Akışı yeniden açmalı. [attempt] 1'den başlar.
  final void Function(int attempt) onRetry;

  /// Denemeler tükenince; asılı bağlantıyı kapatmak için.
  final VoidCallback? onGiveUp;
  final Duration timeout;
  final int maxRetries;
  final DateTime Function() _clock;

  bool _active = false;
  DateTime _lastProgress = DateTime(0);
  int _attempt = 0;
  StallStatus _status = StallStatus.ok;

  StallStatus get status => _status;

  /// Şu anki yeniden bağlanma denemesi (1..[maxRetries]); yoksa 0.
  int get attempt => _attempt;

  /// Yeni bir kanal açıldığında.
  void start() {
    _active = true;
    _attempt = 0;
    _lastProgress = _clock();
    _set(StallStatus.ok);
  }

  void stop() {
    _active = false;
    _attempt = 0;
    _set(StallStatus.ok);
  }

  /// Oynatma konumu ilerlediğinde.
  void progress() {
    if (!_active) return;
    _lastProgress = _clock();
    if (_status != StallStatus.ok) {
      _attempt = 0;
      _set(StallStatus.ok);
    }
  }

  /// Periyodik olarak çağrılır. [playing] false ise kullanıcı duraklatmıştır;
  /// süre sayılmaz.
  void check({required bool playing}) {
    if (!_active) return;
    final now = _clock();
    if (!playing) {
      _lastProgress = now;
      return;
    }
    if (now.difference(_lastProgress) < timeout) return;
    if (_attempt < maxRetries) {
      _attempt++;
      _lastProgress = now;
      _set(StallStatus.reconnecting);
      onRetry(_attempt);
    } else {
      _active = false;
      _set(StallStatus.failed);
      onGiveUp?.call();
    }
  }

  void _set(StallStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }
}
