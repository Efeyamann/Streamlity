import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/parental_lock.dart';
import '../services/settings_store.dart';
import '../ui/tokens.dart';
import '../ui/widgets/logo_mark.dart';
import 'pin_dialog.dart';

Future<void> openSettings(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const SettingsScreen(),
    ));

/// Uygulama ayarları: arayüz dili, ebeveyn denetimi ve hakkında.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final _store = SettingsStore();

  static void _choose(String? code) {
    appLanguage.value = code;
    _store.writeLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    // Sistem dili seçiliyken uygulamanın o an kullandığı dil.
    final current = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsetsDirectional.only(
                start: Space.xs, end: Space.md),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: l.back,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: Space.xs),
                Text(l.sectionSettings, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: appLanguage,
              builder: (context, selected, _) => ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: Space.xl, vertical: Space.lg),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Section(
                            icon: Icons.translate,
                            title: l.settingsLanguage,
                            subtitle: l.settingsLanguageSubtitle,
                            children: [
                              _Choice(
                                label: l.systemLanguage,
                                detail: l.systemLanguageCurrent(
                                    languageName(current)),
                                selected: selected == null,
                                onTap: () => _choose(null),
                              ),
                              Divider(
                                  height: Space.md,
                                  indent: Space.md,
                                  endIndent: Space.md,
                                  color: c.border),
                              for (final (code, name) in appLanguages)
                                _Choice(
                                  label: name,
                                  selected: selected == code,
                                  onTap: () => _choose(code),
                                ),
                            ],
                          ),
                          if (current != 'tr')
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: Space.xs, top: Space.sm),
                              child: Text(l.translationNote,
                                  style: theme.textTheme.bodySmall),
                            ),
                          const SizedBox(height: Space.xl),
                          const _ParentalSection(),
                          const SizedBox(height: Space.xl),
                          _Section(
                            icon: Icons.info_outline,
                            title: l.settingsAbout,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(Space.md),
                                child: Row(
                                  children: [
                                    const LogoMark(size: 40),
                                    const SizedBox(width: Space.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(l.appTitle,
                                              style:
                                                  theme.textTheme.titleMedium),
                                          Text(l.settingsAboutText,
                                              style:
                                                  theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Başlıklı ayar kartı.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: IconSizes.md, color: c.accent),
            const SizedBox(width: Space.xs),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        if (subtitle case final subtitle?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle, style: theme.textTheme.bodySmall),
          ),
        const SizedBox(height: Space.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: Radii.lgAll,
            border: Border.all(color: c.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

/// PIN belirleme, değiştirme, kaldırma ve açılan kilitleri kapatma.
class _ParentalSection extends StatelessWidget {
  const _ParentalSection();

  static void _toast(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _set(BuildContext context) async {
    final message = context.l10n.pinSaved;
    if (await setupPin(context) && context.mounted) _toast(context, message);
  }

  Future<void> _change(BuildContext context) async {
    final l = context.l10n;
    if (!await askPin(context, message: l.pinCurrentMessage) ||
        !context.mounted) {
      return;
    }
    await _set(context);
  }

  Future<void> _remove(BuildContext context) async {
    final l = context.l10n;
    if (!await askPin(context, message: l.pinRemoveMessage)) return;
    await parentalLock.removePin();
    if (context.mounted) _toast(context, l.pinRemoved);
  }

  void _lock(BuildContext context) {
    parentalLock.lock();
    _toast(context, context.l10n.locksClosed);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    return ListenableBuilder(
      listenable: parentalLock,
      builder: (context, _) => _Section(
        icon: Icons.shield_outlined,
        title: l.parentalControl,
        subtitle: l.parentalControlSubtitle,
        children: [
          if (!parentalLock.hasPin)
            _Action(
              icon: Icons.pin_outlined,
              label: l.setPin,
              detail: l.setPinDetail,
              onTap: () => _set(context),
            )
          else ...[
            if (parentalLock.unlocked) ...[
              _Action(
                icon: Icons.lock_outline,
                label: l.lockNow,
                detail: l.lockNowDetail,
                onTap: () => _lock(context),
              ),
              Divider(
                  height: Space.md,
                  indent: Space.md,
                  endIndent: Space.md,
                  color: c.border),
            ],
            _Action(
              icon: Icons.pin_outlined,
              label: l.changePin,
              onTap: () => _change(context),
            ),
            _Action(
              icon: Icons.no_encryption_outlined,
              label: l.removePin,
              detail: l.removePinDetail,
              color: c.danger,
              onTap: () => _remove(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simgeli eylem satırı.
class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Space.sm, vertical: Space.sm),
          child: Row(
            children: [
              Icon(icon, size: IconSizes.md, color: color ?? c.fgMuted),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: color)),
                    if (detail case final detail?)
                      Text(detail, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: IconSizes.md, color: c.fgSubtle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek seçimli satır: seçiliyken kırmızı onay.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Space.sm, vertical: Space.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                      if (detail case final detail?)
                        Text(detail, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: Motion.of(context).fast,
                  opacity: selected ? 1 : 0,
                  child: Icon(Icons.check_circle,
                      size: IconSizes.md, color: c.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
