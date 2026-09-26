<p align="center">
  <img src="assets/branding/streamlity_icon_1024.png" alt="Streamlity" width="128">
</p>

<h1 align="center">Streamlity</h1>

<p align="center">
  A fast, open-source IPTV player for Windows, macOS and Linux.
</p>

---

Streamlity plays live TV, movies and series from your own IPTV provider. Add an
M3U playlist or an Xtream Codes account and get a clean, dark, keyboard-friendly
player built for the desktop: a program guide, catch-up, multiview, parental
controls, and an interface in 12 languages.

> Streamlity is only a player. It doesn't include or sell any channels or
> content. You need a playlist or subscription from a provider, and you're
> responsible for making sure you're allowed to watch what it offers.

## Features

**Live TV**
- M3U / M3U8 playlists (from a URL or a local file) and Xtream Codes accounts
- Electronic program guide (XMLTV) with now/next info, cached between launches
- Catch-up: watch past programs on channels that have an archive
- Multiview: watch up to four channels at once, stacked in 16:9 tiles, with a
  fullscreen grid
- Recently watched channels and favorite categories on the home screen

**Movies and series**
- Browse the provider's movie and series library by category
- Resume where you left off, per movie and per episode
- Audio track and subtitle selection

**Organize and control**
- Global search across channels, movies and series, with filters
- Hide and reorder categories
- Parental controls: lock categories behind a 4-digit PIN; locked content stays
  out of search, the home screen and history
- Playlist credentials are stored in the operating system's secure storage

**Interface**
- Dark, cinema-style design with a compact sidebar
- 12 languages: English, Turkish, Chinese, Hindi, Spanish, Arabic (right-to-left),
  French, Bengali, Portuguese, Russian, Indonesian and German. The app follows
  your system language and can be changed in Settings.

## Download

Get the latest version from the
[Releases](https://github.com/Efeyamann/Streamlity/releases) page.

| Platform | Download |
| --- | --- |
| Windows 10 / 11 (x64) | `Streamlity-<version>-windows-x64-setup.exe` (installer) or `…-windows-x64.zip` (no install) |
| macOS | Coming soon |
| Linux | Coming soon |

The installer doesn't need administrator rights: by default it installs for the
current user only, and you can choose to install for all users.

**"Windows protected your PC"?** Early releases aren't code-signed yet, so
Windows SmartScreen may warn you the first time. Click **More info**, then
**Run anyway**. Every release is built from this repository's source code by
[GitHub Actions](.github/workflows/release.yml).

Until macOS and Linux builds are available, you can build Streamlity from source
on those platforms (see below).

## Keyboard shortcuts

| Key | Action |
| --- | --- |
| Page Up / Page Down | Previous / next channel |
| Backspace | Go back to the last channel |
| M | Mute / unmute |
| F | Fullscreen (in multiview: fullscreen grid) |
| Esc | Leave the fullscreen grid |

Channel up/down keys on remotes and media keyboards work too.

## Building from source

Streamlity is a [Flutter](https://flutter.dev) desktop app. Playback is powered
by [media_kit](https://github.com/media-kit/media-kit) (libmpv).

**Requirements**
- Flutter (stable channel, 3.47 or later)
- Windows: Visual Studio 2022 with the "Desktop development with C++" workload
- macOS: Xcode
- Linux: `clang cmake ninja-build pkg-config libgtk-3-dev libmpv-dev libsecret-1-dev`

**Run**

```bash
git clone https://github.com/Efeyamann/Streamlity.git
cd Streamlity
flutter pub get
flutter run -d windows   # or macos, linux
```

**Release build**

```bash
flutter build windows    # or macos, linux
```

**Tests**

```bash
flutter test
```

## Project structure

```
lib/
  models/     Playlists, channels, EPG and VOD data
  services/   M3U / XMLTV parsers, Xtream client, stores and caches
  screens/    Home, live TV, movies and series, search, settings
  ui/         Design tokens, theme and shared widgets
  l10n/       Translations (one .arb file per language)
assets/
  branding/   Logo and app icon (SVG and PNG)
tool/         Icon generator
```

## Contributing

Bug reports, ideas and pull requests are welcome, especially:

- **Translations.** Strings live in `lib/l10n/app_<language>.arb`, with Turkish
  (`app_tr.arb`) as the template. If you add a string, add it to every language
  and run `flutter gen-l10n`; `test/l10n_test.dart` checks that nothing is
  missing. Corrections from native speakers are very welcome.
- **Testing on macOS and Linux.** Most development happens on Windows.

Please run `flutter analyze` and `flutter test` before opening a pull request.

## Releasing

1. Bump `version` in `pubspec.yaml` (for example `0.2.0+2`) and commit.
2. Tag the commit with the same version and push the tag:
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```
3. The [Release workflow](.github/workflows/release.yml) builds and tests the app
   and opens a draft release with the Windows installer and zip.
4. Review the draft on GitHub, edit the notes and publish it.

The workflow can also be started by hand from the Actions tab to build without
releasing; the files appear under the run's artifacts.

## License

Streamlity is free software, released under the
[GNU General Public License v3.0](LICENSE). You can use, study, share and
change it; if you distribute a modified version, it must stay under the same
license with its source code available.
