#!/bin/bash
set -e

SRC_DIR="/download1"
WEBKIT_VERSION="2.38.6"
WEBKIT_PKG="webkitgtk-${WEBKIT_VERSION}.tar.xz"
WEBKIT_URL="https://webkitgtk.org/releases/${WEBKIT_PKG}"
SURF_REPO="https://github.com/lkiesow/surf.git"

mkdir -p $SRC_DIR
cd $SRC_DIR

# ==============================
# Step 1: Build WebKitGTK2
# ==============================
echo "[*] Building WebKitGTK2 ${WEBKIT_VERSION}..."

if [ ! -f "$WEBKIT_PKG" ]; then
  echo "[*] Downloading WebKitGTK2..."
  wget --no-check-certificate "$WEBKIT_URL"
fi

echo "[*] Extracting WebKitGTK2..."
rm -rf webkitgtk-${WEBKIT_VERSION}
tar xf $WEBKIT_PKG
cd webkitgtk-${WEBKIT_VERSION}

echo "[*] Creating build directory..."
mkdir -p build && cd build

echo "[*] Configuring WebKitGTK2..."
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DENABLE_GEOLOCATION=OFF \
  -DENABLE_GEOCLUE=OFF \
  -DENABLE_MM_GLIB=OFF \
  -DENABLE_WEB_AUDIO=OFF \
  -DENABLE_VIDEO=OFF \
  -DUSE_SOUP2=ON \
  -DENABLE_MINIBROWSER=OFF \
  -DENABLE_DOCUMENTATION=OFF \
  -DUSE_LIBHYPHEN=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DUSE_SYSTEM_MALLOC=ON \
  -DUSE_SYSTEMD=OFF

echo "[*] Building WebKitGTK2..."
make -j$(nproc)

echo "[*] Installing WebKitGTK2..."
sudo make install

cd $SRC_DIR

# ==============================
# Step 2: Build Surf
# ==============================
echo "[*] Building Surf browser..."

if [ -d "surf" ]; then
  echo "[*] Updating existing Surf repo..."
  cd surf && git pull && cd ..
else
  git clone $SURF_REPO
fi

cd surf

echo "[*] Setting environment for WebKitGTK2..."
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig
export CFLAGS="$(pkg-config --cflags gtk+-3.0 webkit2gtk-4.0)"
export LDFLAGS="$(pkg-config --libs gtk+-3.0 webkit2gtk-4.0)"

echo "[*] Building Surf..."
make clean
make

echo "[*] Installing Surf..."
sudo make install

echo "[*] Build completed successfully!"
