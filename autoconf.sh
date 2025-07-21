#!/bin/bash

# Direktori kerja untuk Autoconf 2.13
mkdir -p /web1/autoconf-2.13
cd /web1/autoconf-2.13

# Unduh sumber Autoconf 2.13
echo "Mengunduh file sumber autoconf-2.13.tar.gz..."
wget --no-check-certificate https://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz

# Unduh patch untuk Autoconf 2.13
echo "Mengunduh patch untuk autoconf-2.13..."
wget --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/9.0/autoconf-2.13-consolidated_fixes-1.patch

# Ekstrak file sumber
echo "Mengekstrak file sumber..."
tar -xzf autoconf-2.13.tar.gz
cd autoconf-2.13

# Terapkan patch
echo "Menerapkan patch..."
patch -Np1 -i ../autoconf-2.13-consolidated_fixes-1.patch

# Ubah nama file agar tidak menimpa versi yang lebih baru
echo "Mengubah nama file autoconf.texi menjadi autoconf213.texi..."
mv -v autoconf.texi autoconf213.texi

# Hapus autoconf.info untuk mencegah penimpaannya
echo "Menghapus file autoconf.info..."
rm -v autoconf.info

# Konfigurasi build
echo "Menyiapkan konfigurasi build..."
./configure --prefix=/usr --program-suffix=2.13

# Kompilasi Autoconf
echo "Kompilasi Autoconf 2.13..."
make

# Instalasi sebagai root
echo "Menginstal Autoconf 2.13..."
sudo make install

# Instalasi info file
echo "Menyalin file info..."
sudo install -v -m644 autoconf213.info /usr/share/info
sudo install-info --info-dir=/usr/share/info autoconf213.info

# Pembersihan
echo "Membersihkan direktori sementara..."
cd /web1
rm -rf /web1/autoconf-2.13

echo "Instalasi Autoconf 2.13 selesai!"
