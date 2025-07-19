#!/bin/bash
# install_glib_stack.sh
# Bangun PCRE -> GLib (tahap1) -> GObject Introspection -> GLib (tahap2) -> WebKitGTK
# Jalankan sebagai root di sistem LFS/BLFS.

set -euo pipefail

DOWNLOAD_DIR="/home/leakos/downloads"
PREFIX="/usr"             # paket inti BLFS ke /usr
BUILD_JOBS="$(nproc)"     # paralel build

# ====== URL ======
PCRE_URL="https://ftp.exim.org/pub/pcre/pcre-8.45.tar.bz2"
GLIB_URL="https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz"
GI_URL="https://download.gnome.org/sources/gobject-introspection/1.72/gobject-introspection-1.72.0.tar.xz"
WEBKITGTK_URL="https://webkitgtk.org/releases/webkitgtk-2.36.7.tar.xz"

# Opsional patch GLib: simpan file di $DOWNLOAD_DIR
GLIB_PATCH="$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch"

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# ------------------------------------------------------------
# helper: download & extract
# arg1=url
# sets: TARFILE, SRCDIR
# ------------------------------------------------------------
fetch_and_extract() {
  local url="$1"
  local tarfile="$(basename "$url")"
  local srcdir
  echo "==> Mengunduh: $tarfile"
  wget --no-check-certificate -c "$url" -O "$tarfile"
  echo "==> Mengekstrak: $tarfile"
  tar -xf "$tarfile"
  # nama direktori sumber = tarfile tanpa .tar.*
  srcdir="$(tar -tf "$tarfile" | head -1 | cut -d/ -f1)"
  if [[ ! -d "$srcdir" ]]; then
    echo "Gagal deteksi direktori sumber dari $tarfile" >&2
    exit 1
  fi
  TARFILE="$tarfile"
  SRCDIR="$srcdir"
}

# ------------------------------------------------------------
# PCRE (autotools)
# ------------------------------------------------------------
build_pcre() {
  fetch_and_extract "$PCRE_URL"
  cd "$SRCDIR"

  ./configure --prefix="$PREFIX" \
    --enable-unicode-properties \
    --enable-pcre16 \
    --enable-pcre32 \
    --enable-pcregrep-libz \
    --enable-pcregrep-libbz2 \
    --enable-pcretest-libreadline \
    --disable-static

  make -j"$BUILD_JOBS"
  make install

  cd "$DOWNLOAD_DIR"
}

# ------------------------------------------------------------
# GLib common build function
# $1 = extra meson opts
# $2 = label (tahap1/tahap2)
# ------------------------------------------------------------
build_glib() {
  local extra="$1"
  local label="$2"
  fetch_and_extract "$GLIB_URL"
  cd "$SRCDIR"

  # patch opsional
  if [[ -f "$GLIB_PATCH" ]]; then
    echo "==> Menerapkan patch GLib..."
    patch -Np1 -i "$GLIB_PATCH"
  fi

  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    -Dman=false \               # jangan bangun man (hindari DocBook online)
    $extra \
    --wrap-mode=nodownload \
    ..
  ninja -j"$BUILD_JOBS"
  ninja install

  # dokumentasi referensi (HTML) opsional: butuh tools lain; skip dulu.

  cd "$DOWNLOAD_DIR"
}

# ------------------------------------------------------------
# GObject Introspection (Meson)
# ------------------------------------------------------------
build_gi() {
  fetch_and_extract "$GI_URL"
  cd "$SRCDIR"
  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    --wrap-mode=nodownload \
    ..
  ninja -j"$BUILD_JOBS"
  ninja install
  cd "$DOWNLOAD_DIR"
}

# ------------------------------------------------------------
# WebKitGTK (Meson; sangat berat; banyak dep)
# ------------------------------------------------------------
build_webkitgtk() {
  fetch_and_extract "$WEBKITGTK_URL"
  cd "$SRCDIR"
  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    -Dman=false \
    --wrap-mode=nodownload \
    ..
  ninja -j"$BUILD_JOBS"
  ninja install
  cd "$DOWNLOAD_DIR"
}

# ============================================================
# EXECUTION ORDER
# ============================================================
echo "========== [1/5] PCRE =========="
build_pcre

echo "========== [2/5] GLib tahap-1 (tanpa introspection) =========="
build_glib "-Dintrospection=disabled" "tahap1"

echo "========== [3/5] GObject Introspection =========="
build_gi

echo "========== [4/5] GLib tahap-2 (aktifkan introspection) =========="
# Rebuild GLib dengan introspection enabled.
build_glib "-Dintrospection=enabled" "tahap2"

echo "========== [5/5] WebKitGTK =========="
build_webkitgtk

# ============================================================
# Verifikasi
# ============================================================
echo "========== Verifikasi =========="
pkg-config --modversion glib-2.0 || echo "GLib tidak terdeteksi!"
pkg-config --modversion gobject-2.0 || true
pkg-config --modversion gthread-2.0 || true
pkg-config --modversion gobject-introspection-1.0 || echo "GI tidak terdeteksi!"
pkg-config --modversion webkit2gtk-4.0 || echo "WebKitGTK tidak terdeteksi!"
if command -v pcre-config >/dev/null 2>&1; then
  pcre-config --version
else
  pkg-config --modversion libpcre || true
fi

echo "=== Selesai! ==="
