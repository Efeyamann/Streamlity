# libmpv

`mpv-dev-x86_64-20260928-git-e470f8986e.7z` is the libmpv build from
[shinchiro/mpv-winbuild-cmake](https://github.com/shinchiro/mpv-winbuild-cmake/releases/tag/20260928)
(mpv v0.41.0-1087-ge470f8986, GPL). `windows/CMakeLists.txt` installs its
`libmpv-2.dll` over the older one bundled by media_kit, which doesn't support
NVIDIA RTX Video Super Resolution.

To update: download a newer `mpv-dev-x86_64-*.7z`, replace the file here and
update the file name and SHA256 in `windows/CMakeLists.txt`. Check that live
channels, HLS streams with redirects and RTX VSR still work.
