# Code signing policy

Free code signing provided by [SignPath.io](https://about.signpath.io/),
certificate by [SignPath Foundation](https://signpath.org/).

## What gets signed

Only the Windows files published on the
[Releases](https://github.com/Efeyamann/Streamlity/releases) page: the
Streamlity installer (`Streamlity-<version>-windows-x64-setup.exe`) and the
programs inside the zip. They are built from this repository's source code by
the [Release workflow](.github/workflows/release.yml) on GitHub Actions. Nothing
built on a personal computer is signed.

Streamlity bundles open-source libraries, such as Flutter and media_kit
(libmpv). Those are signed only as part of Streamlity's own release files.

## Team roles

| Role | Members |
| --- | --- |
| Committers and reviewers | [Efeyamann](https://github.com/Efeyamann) |
| Approvers | [Efeyamann](https://github.com/Efeyamann) |

- **Committers** can change the source code in this repository.
- **Reviewers** review changes from other contributors before they're merged.
- **Approvers** approve each signing request by hand, one release at a time.

Everyone in these roles uses multi-factor authentication for GitHub and
SignPath.

## Privacy policy

This program will not transfer any information to other networked systems
unless specifically requested by the user or the person installing or
operating it.

Streamlity only connects to the playlists, Xtream Codes servers and program
guides that you add yourself, to load channels, programs and video streams.
It has no analytics, telemetry, ads or accounts. Your settings, favorites and
watch history stay on your computer, and playlist passwords are kept in your
operating system's secure storage.
