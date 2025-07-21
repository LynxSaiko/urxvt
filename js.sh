#!/bin/bash

# Pastikan direktori /web1 sudah ada
mkdir -p /web1/mozjs-build
cd /web1/mozjs-build

# Unduh file sumber Mozilla JS 60.8.0
echo "Mengunduh file sumber mozjs-60.8.0.tar.bz2..."
wget http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/mozjs/mozjs-60.8.0.tar.bz2

# Ekstrak file sumber
echo "Mengekstrak file sumber..."
tar -xjf mozjs-60.8.0.tar.bz2
cd mozjs-60.8.0

# Persiapkan untuk kompilasi
echo "Menyiapkan konfigurasi build..."
mkdir mozjs-build
cd mozjs-build
../js/src/configure --prefix=/usr \
                    --with-intl-api \
                    --with-system-zlib \
                    --with-system-icu \
                    --disable-jemalloc \
                    --enable-readline

# Kompilasi JS
echo "Kompilasi JS-60.8.0..."
make

# Instalasi (jalankan sebagai root)
echo "Menginstal JS-60.8.0..."
sudo make install

# Bersihkan direktori sementara
echo "Membersihkan direktori sementara..."
cd /web1
rm -rf /web1/mozjs-build

echo "Instalasi JS-60.8.0 selesai!"
