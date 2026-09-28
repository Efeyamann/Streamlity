#!/usr/bin/env bash
# Flutter'ın Linux paketinden (build/linux/x64/release/bundle) bir .deb üretir.
# Kullanım: build_deb.sh <sürüm> <bundle klasörü> <çıktı klasörü>
# Bağımlılıklar dpkg-shlibdeps ile ikili dosyalardan çıkarılır; bu yüzden
# paketin derlendiği dağıtımla (ubuntu-latest) uyumlu sistemlerde çalışır.
set -euo pipefail

version=$1
bundle=$(realpath "$2")
out=$(realpath "$3")
here=$(dirname "$(realpath "$0")")
app_id=io.github.efeyamann.streamlity

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
root="$work/root"

mkdir -p "$root/opt/streamlity" "$root/usr/bin" "$root/DEBIAN" \
  "$root/usr/share/applications" "$root/usr/share/icons/hicolor/scalable/apps"
cp -a "$bundle/." "$root/opt/streamlity/"
ln -s /opt/streamlity/streamlity "$root/usr/bin/streamlity"
install -m644 "$here/$app_id.desktop" "$root/usr/share/applications/"
install -m644 "$here/../../assets/branding/streamlity_icon.svg" \
  "$root/usr/share/icons/hicolor/scalable/apps/$app_id.svg"

# dpkg-shlibdeps bir debian/control bekler; paketle gelen lib/ klasörü özel
# kütüphane dizini olarak verilir, onlar bağımlılık sayılmaz.
mkdir -p "$work/debian"
printf 'Source: streamlity\n\nPackage: streamlity\nArchitecture: amd64\n' \
  > "$work/debian/control"
depends=$(cd "$work" && dpkg-shlibdeps -O --ignore-missing-info \
  -l"$root/opt/streamlity/lib" \
  -e"$root/opt/streamlity/streamlity" "$root"/opt/streamlity/lib/*.so \
  | sed -n 's/^shlibs:Depends=//p')
if [[ $depends != *libmpv* ]]; then
  echo "libmpv bağımlılığı bulunamadı: $depends" >&2
  exit 1
fi

size=$(du -sk "$root" | cut -f1)
cat > "$root/DEBIAN/control" <<EOF
Package: streamlity
Version: $version
Architecture: amd64
Maintainer: Streamlity contributors <eyamansir@gmail.com>
Installed-Size: $size
Depends: $depends
Section: video
Priority: optional
Homepage: https://github.com/Efeyamann/Streamlity
Description: Open-source IPTV player
 Streamlity plays live TV, movies and series from your own IPTV provider
 (M3U playlists or Xtream Codes accounts), with a program guide, catch-up,
 multiview and parental controls.
EOF

mkdir -p "$out"
dpkg-deb --build --root-owner-group "$root" \
  "$out/Streamlity-$version-linux-amd64.deb"
