#!/bin/bash
# install_glib_stack_no_pcre.sh
# Jalankan sebagai root

set -euo pipefail

DOWNLOAD_DIR="/home/leakos/downloads"
PREFIX="/usr"
BUILD_JOBS="$(nproc)"

# ===== URL =====
GLIB_URL="https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz"
GI_URL="https://download.gnome.org/sources/gobject-introspection/1.72/gobject-introspection-1.72.0.tar.xz"
WEBKITGTK_URL="https://webkitgtk.org/releases/webkitgtk-2.36.7.tar.xz"

# Patch opsional untuk GLib
GLIB_PATCH="$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch"

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# ------------------------------------------------------------
# helper: download & extract
# ------------------------------------------------------------
fetch_and_extract() {
  local url="$1"
  local tarfile="$(basename "$url")"
  echo "==> Mengunduh: $tarfile"
  wget --no-check-certificate -c "$url" -O "$tarfile"
  echo "==> Mengekstrak: $tarfile"
  tar -xf "$tarfile"
  SRCDIR="$(tar -tf "$tarfile" | head -1 | cut -d/ -f1)"
  cd "$SRCDIR"
}

# ------------------------------------------------------------
# GLib build
# ------------------------------------------------------------
build_glib() {
  local extra="$1"
  echo "==> Build GLib ($extra)"
  fetch_and_extract "$GLIB_URL"

  if [[ -f "$GLIB_PATCH" ]]; then
    echo "==> Menerapkan patch GLib..."
    patch -Np1 -i "$GLIB_PATCH"
  fi

  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    -Dman=false \
    $extra \
    --wrap-mode=nodownload ..
  ninja -j"$BUILD_JOBS"
  ninja install
  cd "$DOWNLOAD_DIR"
}

# ------------------------------------------------------------
# GObject Introspection
# ------------------------------------------------------------
build_gi() {
  echo "==> Build GObject Introspection"
  fetch_and_extract "$GI_URL"
  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    --wrap-mode=nodownload ..
  ninja -j"$BUILD_JOBS"
  ninja install
  cd "$DOWNLOAD_DIR"
}

# ------------------------------------------------------------
# WebKitGTK
# ------------------------------------------------------------
build_webkitgtk() {
  echo "==> Build WebKitGTK"
  fetch_and_extract "$WEBKITGTK_URL"
  mkdir build && cd build
  meson setup --prefix="$PREFIX" \
    --buildtype=release \
    -Dman=false \
    --wrap-mode=nodownload ..
  ninja -j"$BUILD_JOBS"
  ninja install
  cd "$DOWNLOAD_DIR"
}

# ============================================================
# EXECUTION ORDER
# ============================================================
echo "========== [1/4] GLib tahap-1 (tanpa introspection) =========="
build_glib "-Dintrospection=disabled"

echo "========== [2/4] GObject Introspection =========="
build_gi

echo "========== [3/4] GLib tahap-2 (aktifkan introspection) =========="
build_glib "-Dintrospection=enabled"

echo "========== [4/4] WebKitGTK =========="
build_webkitgtk

# ============================================================
# Verifikasi
# ============================================================
echo "========== Verifikasi =========="
pkg-config --modversion glib-2.0 || echo "GLib tidak terdeteksi!"
pkg-config --modversion gobject-introspection-1.0 || echo "GI tidak terdeteksi!"
pkg-config --modversion webkit2gtk-4.0 || echo "WebKitGTK tidak terdeteksi!"

echo "=== Instalasi selesai! ==="
