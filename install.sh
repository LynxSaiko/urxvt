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
  if [[ "$PACKAGE_TAR" == *.tar.xz ]]; then
    tar -xvf "$PACKAGE_TAR"
  elif [[ "$PACKAGE_TAR" == *.tar.bz2 ]]; then
    tar -xvjf "$PACKAGE_TAR"
  fi
  cd "$PACKAGE_NAME"

  # Terapkan patch GLib jika tersedia
  if [ -f "$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch" ]; then
    echo "Menerapkan patch untuk menghapus peringatan di GLib..."
    patch -Np1 -i "$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch"
  fi

# Menyusun dengan Meson dan Ninja (untuk GLib dan WebKitGTK)
  if [ "$PACKAGE_NAME" == "glib-2.72.3" ] || [ "$PACKAGE_NAME" == "webkitgtk-2.36.7" ]; then
    echo "Menyiapkan dan mengonfigurasi $PACKAGE_NAME dengan Meson dan Ninja..."
    mkdir build
    cd build
    meson --prefix="$INSTALL_DIR" \
          --buildtype=release \
          -Dman=false \
          $extra \
          --wrap-mode=nodownload .. \
          && ninja
    if [ $? -ne 0 ]; then
      echo "Gagal mengonfigurasi dan membangun $PACKAGE_NAME"
      exit 1
    fi
  else
    # Menyusun dengan configure dan make (untuk PCRE dan GObject Introspection)
    echo "Menyiapkan dan mengonfigurasi $PACKAGE_NAME..."
    ./configure --prefix="$INSTALL_DIR" \
                --enable-unicode-properties \
                --enable-pcre16 \
                --enable-pcre32 \
                --enable-pcregrep-libz \
                --enable-pcregrep-libbz2 \
                --enable-pcretest-libreadline \
                --disable-static
    if [ $? -ne 0 ]; then
      echo "Gagal mengonfigurasi $PACKAGE_NAME"
      exit 1
    fi

    # Menyusun dengan make
    echo "Membangun $PACKAGE_NAME..."
    make
    if [ $? -ne 0 ]; then
      echo "Gagal membangun $PACKAGE_NAME"
      exit 1
    fi
  fi

# Menginstal dengan make install atau ninja install
  echo "Menginstal $PACKAGE_NAME..."
  if [ "$PACKAGE_NAME" == "glib-2.72.3" ] || [ "$PACKAGE_NAME" == "webkitgtk-2.36.7" ]; then
    sudo ninja install
  else
    sudo make install
  fi

  # Salin dokumentasi (untuk GLib dan WebKitGTK)
  if [ "$PACKAGE_NAME" == "glib-2.72.3" ]; then
    mkdir -p /usr/share/doc/glib-2.72.3
    cp -r ../docs/reference/{gio,glib,gobject} /usr/share/doc/glib-2.72.3
  fi

  # Kembali ke direktori unduhan
  cd "$DOWNLOAD_DIR"
}

# URL untuk mengunduh GLib 2.72.3
GLIB_URL="https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz"
GOBJECT_INTROSPECTION_URL="https://download.gnome.org/sources/gobject-introspection/1.72/gobject-introspection-1.72.0.tar.xz"
WEBKITGTK_URL="https://webkitgtk.org/releases/webkitgtk-2.36.7.tar.xz"
PCRE_URL="https://ftp.exim.org/pub/pcre/pcre-8.40.tar.bz2"  # Update URL ke versi yang tepat

# Mengunduh dan menginstal GLib 2.72.3
install_package "glib-2.72.3" "$GLIB_URL"

# Mengunduh dan menginstal GObject Introspection 1.72.0
install_package "gobject-introspection-1.72.0" "$GOBJECT_INTROSPECTION_URL"

# Mengunduh dan menginstal WebKitGTK 2.36.7
install_package "webkitgtk-2.36.7" "$WEBKITGTK_URL"

# Mengunduh dan menginstal PCRE 8.40 (versi yang benar)
install_package "pcre-8.40" "$PCRE_URL"

# Verifikasi instalasi
echo "Verifikasi instalasi GLib..."
pkg-config --modversion glib-2.0
pkg-config --modversion gobject-2.0
pkg-config --modversion gthread-2.0

echo "Verifikasi instalasi GObject Introspection..."
pkg-config --modversion gobject-introspection-1.0

echo "Verifikasi instalasi WebKitGTK..."
pkg-config --modversion webkit2gtk-4.0

echo "Verifikasi instalasi PCRE..."
pcre-config --version

echo "Instalasi selesai!"
