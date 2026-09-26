import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../services/parental_lock.dart';
import '../ui/tokens.dart';

/// PIN'i sorar; doğru girilirse true. [unlock] ise kilitli kategoriler
/// uygulama kapanana kadar açılır.
Future<bool> askPin(
  BuildContext context, {
  required String message,
  bool unlock = false,
}) async {
  final l = context.l10n;
  final pin = await _showPinDialog(
    context,
    title: l.pinEnterTitle,
    message: message,
    validate: (pin) => parentalLock.check(pin) ? null : l.pinWrong,
  );
  if (pin == null) return false;
  if (unlock) parentalLock.unlock(pin);
  return true;
}

/// Kilitler kapalıysa kategoriyi açmak için PIN sorar; açıksa hemen true.
Future<bool> unlockCategories(BuildContext context) async =>
    !parentalLock.active ||
    await askPin(context,
        message: context.l10n.pinUnlockMessage, unlock: true);

/// Yeni PIN'i iki kez sorup kaydeder. Kaydedilirse true.
Future<bool> setupPin(BuildContext context) async {
  final l = context.l10n;
  final first = await _showPinDialog(
    context,
    title: l.pinNewTitle,
    message: l.pinNewMessage,
    validate: (_) => null,
  );
  if (first == null || !context.mounted) return false;
  final second = await _showPinDialog(
    context,
    title: l.pinConfirmTitle,
    message: l.pinConfirmMessage,
    validate: (pin) => pin == first ? null : l.pinMismatch,
  );
  if (second == null) return false;
  await parentalLock.setPin(second);
  return true;
}

/// PIN kutusu. [validate] hata metni döndürürse kutu temizlenir ve pencere
/// açık kalır; null döndürürse girilen PIN'le kapanır.
Future<String?> _showPinDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String? Function(String pin) validate,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) =>
          _PinDialog(title: title, message: message, validate: validate),
    );

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.title,
    required this.message,
    required this.validate,
  });

  final String title;
  final String message;
  final String? Function(String pin) validate;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _complete => _controller.text.length == pinLength;

  void _submit() {
    if (!_complete) return;
    final pin = _controller.text;
    final error = widget.validate(pin);
    if (error == null) {
      Navigator.of(context).pop(pin);
      return;
    }
    setState(() => _error = error);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    return AlertDialog(
      icon: Icon(Icons.lock_outline, color: c.accent),
      title: Text(widget.title),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.fgMuted)),
            const SizedBox(height: Space.lg),
            Center(
              child: SizedBox(
                width: 180,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: true,
                  obscureText: true,
                  obscuringCharacter: '●',
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(letterSpacing: Space.md),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(pinLength),
                  ],
                  decoration: InputDecoration(
                    // Harf aralığı son hanenin ardına da eklenir; aynı
                    // genişlikte boşlukla haneler ortada kalsın.
                    prefixIcon: const SizedBox(width: Space.md),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: Space.md),
                    hintText: '○' * pinLength,
                    errorText: _error,
                  ),
                  onChanged: (_) {
                    setState(() {});
                    if (_complete) _submit();
                  },
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _complete ? _submit : null,
          child: Text(l.confirm),
        ),
      ],
    );
  }
}
