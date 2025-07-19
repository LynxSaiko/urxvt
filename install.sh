#!/bin/bash

# Direktori untuk menyimpan file unduhan
DOWNLOAD_DIR="/home/leakos/downloads"
INSTALL_DIR="/usr/local"

# Membuat direktori unduhan jika belum ada
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Fungsi untuk mengunduh dan menginstal paket
install_package() {
  local PACKAGE_NAME=$1
  local PACKAGE_URL=$2
  local PACKAGE_TAR=${PACKAGE_NAME}.tar.xz

  # Mengunduh file tarball dengan --no-check-certificate
  echo "Mengunduh $PACKAGE_NAME..."
  wget --no-check-certificate "$PACKAGE_URL" -O "$PACKAGE_TAR"
  if [ $? -ne 0 ]; then
    echo "Gagal mengunduh $PACKAGE_NAME"
    exit 1
  fi

  # Mengekstrak file tarball
  echo "Mengekstrak $PACKAGE_NAME..."
  tar -xvf "$PACKAGE_TAR"
  cd "$PACKAGE_NAME"

  # Terapkan patch opsional (jika ada)
  if [ -f "../glib-2.72.3-skip_warnings-1.patch" ]; then
    echo "Menerapkan patch untuk menghapus peringatan..."
    patch -Np1 -i "../glib-2.72.3-skip_warnings-1.patch"
  fi

  # Menyusun dengan Meson dan Ninja
  echo "Menyiapkan dan mengonfigurasi $PACKAGE_NAME menggunakan Meson..."
  mkdir build
  cd build
  meson --prefix="$INSTALL_DIR" \
        --buildtype=release \
        -Dman=true \
        .. \
        && ninja

  if [ $? -ne 0 ]; then
    echo "Gagal mengonfigurasi dan membangun $PACKAGE_NAME dengan Meson dan Ninja"
    exit 1
  fi

  # Menginstal dengan Ninja
  echo "Menginstal $PACKAGE_NAME..."
  sudo ninja install

  # Salin dokumentasi
  mkdir -p /usr/share/doc/glib-2.72.3
  cp -r ../docs/reference/{gio,glib,gobject} /usr/share/doc/glib-2.72.3

  # Kembali ke direktori unduhan
  cd "$DOWNLOAD_DIR"
}

# Cek apakah file patch ada di direktori
if [ ! -f "../glib-2.72.3-skip_warnings-1.patch" ]; then
  echo "File patch tidak ditemukan. Anda dapat mengunduhnya jika perlu."
fi

# URL yang benar untuk mengunduh GLib 2.72.3
GLIB_URL="https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz"
GOBJECT_INTROSPECTION_URL="https://download.gnome.org/sources/gobject-introspection/1.72/gobject-introspection-1.72.0.tar.xz"
WEBKITGTK_URL="https://webkitgtk.org/releases/webkitgtk-2.36.7.tar.xz"

# Mengunduh dan menginstal GLib 2.72.3
install_package "glib-2.72.3" "$GLIB_URL"

# Mengunduh dan menginstal GObject Introspection 1.72.0
install_package "gobject-introspection-1.72.0" "$GOBJECT_INTROSPECTION_URL"

# Mengunduh dan menginstal WebKitGTK 2.36.7
install_package "webkitgtk-2.36.7" "$WEBKITGTK_URL"

# Verifikasi instalasi
echo "Verifikasi instalasi GLib..."
pkg-config --modversion glib-2.0
pkg-config --modversion gobject-2.0
pkg-config --modversion gthread-2.0

echo "Verifikasi instalasi GObject Introspection..."
pkg-config --modversion gobject-introspection-1.0

echo "Verifikasi instalasi WebKitGTK..."
pkg-config --modversion webkit2gtk-4.0

echo "Instalasi selesai!"
