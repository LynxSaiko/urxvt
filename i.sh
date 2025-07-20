#!/bin/bash

wget --no-check-certificate https://download.gnome.org/sources/libsoup/2.74/libsoup-2.74.2.tar.xz
wget --no-check-certificate https://download.gnome.org/sources/glib-networking/2.72/glib-networking-2.72.2.tar.xz
wget --no-check-certificate https://github.com/rockdaboot/libpsl/releases/download/0.21.1/libpsl-0.21.1.tar.gz

tar -xf libpsl-0.21.1.tar.gz
cd libpsl-0.21.1
sed -i 's/env python/&3/' src/psl-make-dafsa &&
./configure --prefix=/usr --disable-static       &&
make -j$(nproc)
make install

tar -xf glib-networking-2.72.2.tar.xz
cd glib-networking-2.72.2
mkdir build &&
cd    build &&

meson --prefix=/usr       \
      --buildtype=release &&
ninja -j$(nproc)
ninja install



tar -xf libsoup-2.74.2.tar.xz
cd libsoup-2.74.2
sed -i 's/env python/&3/' src/psl-make-dafsa &&
./configure --prefix=/usr --disable-static       &&
make -j$(nproc)
make install
