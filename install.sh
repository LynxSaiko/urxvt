#!/bin/bash

DOWNLOAD_DIR="/home/leakos/downloads"
INSTALL_DIR="/usr/local"

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Fungsi untuk mengunduh dan menginstal paket
install_package() {
  local PACKAGE_NAME=$1
  local PACKAGE_URL=$2
  local USE_MESON=$3

  local PACKAGE_TAR=$(basename "$PACKAGE_URL")

  echo "Mengunduh $PACKAGE_NAME..."
  wget --no-check-certificate -c "$PACKAGE_URL" -O "$PACKAGE_TAR"
  if [ $? -ne 0 ]; then
    echo "Gagal mengunduh $PACKAGE_NAME"
    exit 1
  fi

  echo "Mengekstrak $PACKAGE_NAME..."
  tar -xf "$PACKAGE_TAR"
  cd "$PACKAGE_NAME"

  # Patch khusus GLib
  if [ "$PACKAGE_NAME" == "glib-2.72.3" ] && [ -f "$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch" ]; then
    patch -Np1 -i "$DOWNLOAD_DIR/glib-2.72.3-skip_warnings-1.patch"
  fi

  if [ "$USE_MESON" == "yes" ]; then
    echo "Menyiapkan dan mengonfigurasi $PACKAGE_NAME dengan Meson dan Ninja..."
    mkdir -p build && cd build
    meson setup --prefix="$INSTALL_DIR" \
                --buildtype=release \
                -Dman=false \
                --wrap-mode=nodownload ..
    ninja
  else
    echo "Menyiapkan dan mengonfigurasi $PACKAGE_NAME..."
    ./configure --prefix="$INSTALL_DIR" --disable-static
    make
  fi

  echo "Menginstal $PACKAGE_NAME..."
  if [ "$USE_MESON" == "yes" ]; then
    sudo ninja install
  else
    sudo make install
  fi

  cd "$DOWNLOAD_DIR"
}

# URL Paket
GLIB_URL="https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz"
GI_URL="https://download.gnome.org/sources/gobject-introspection/1.72/gobject-introspection-1.72.0.tar.xz"
WEBKITGTK_URL="https://webkitgtk.org/releases/webkitgtk-2.36.7.tar.xz"

# 1. Build GLib tahap awal (tanpa introspection)
install_package "glib-2.72.3" "$GLIB_URL" "yes"

# 2. Build GObject Introspection
install_package "gobject-introspection-1.72.0" "$GI_URL" "yes"

# 3. Rebuild GLib (aktifkan introspection)
echo "Rebuild GLib dengan introspection..."
cd "$DOWNLOAD_DIR"
rm -rf glib-2.72.3
wget --no-check-certificate -c "$GLIB_URL" -O glib-2.72.3.tar.xz
tar -xf glib-2.72.3.tar.xz
cd glib-2.72.3
mkdir build && cd build
meson setup --prefix="$INSTALL_DIR" \
            --buildtype=release \
            -Dman=false \
            -Dintrospection=enabled \
            --wrap-mode=nodownload ..
ninja
sudo ninja install
cd "$DOWNLOAD_DIR"

# 4. Build WebKitGTK
install_package "webkitgtk-2.36.7" "$WEBKITGTK_URL" "yes"

# Verifikasi
echo "Verifikasi instalasi GLib..."
pkg-config --modversion glib-2.0
pkg-config --modversion gobject-2.0
pkg-config --modversion gthread-2.0

echo "Verifikasi GObject Introspection..."
pkg-config --modversion gobject-introspection-1.0

echo "Verifikasi WebKitGTK..."
pkg-config --modversion webkit2gtk-4.0

echo "Instalasi selesai!"
