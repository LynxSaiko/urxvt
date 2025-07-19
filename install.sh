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

  # Menyiapkan dan mengonfigurasi build
  echo "Mengonfigurasi $PACKAGE_NAME..."
  ./configure --prefix="$INSTALL_DIR"
  if [ $? -ne 0 ]; then
    echo "Gagal mengonfigurasi $PACKAGE_NAME"
    exit 1
  fi

  # Membangun dan menginstal
  echo "Membangun dan menginstal $PACKAGE_NAME..."
  make -j$(nproc) && sudo make install
  if [ $? -ne 0 ]; then
    echo "Gagal menginstal $PACKAGE_NAME"
    exit 1
  fi

  # Kembali ke direktori unduhan
  cd "$DOWNLOAD_DIR"
}

# Mengunduh dan menginstal glib-2.0
install_package "glib-2.0" "https://ftp.gnome.org/pub/gnome/sources/glib/2.68/glib-2.68.4.tar.xz"

# Mengunduh dan menginstal gobject-2.0 (termasuk dalam glib)
# Tidak perlu mengunduh terpisah, karena bagian dari glib-2.0

# Mengunduh dan menginstal gthread-2.0 (termasuk dalam glib)
# Tidak perlu mengunduh terpisah, karena bagian dari glib-2.0

# Mengunduh dan menginstal webkit-1.0
install_package "webkit-1.0" "https://github.com/WebKit/webkitgtk/archive/refs/tags/1.0.tar.gz"

# Verifikasi instalasi
echo "Verifikasi instalasi GLib..."
pkg-config --modversion glib-2.0
pkg-config --modversion gobject-2.0
pkg-config --modversion gthread-2.0

echo "Verifikasi instalasi WebKit..."
pkg-config --modversion webkitgtk-1.0

echo "Instalasi selesai!"
