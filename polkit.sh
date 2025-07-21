#!/bin/bash

# Direktori kerja untuk Polkit
mkdir -p /web1/polkit-0.116
cd /web1/polkit-0.116

# Unduh sumber Polkit 0.116
echo "Mengunduh file sumber polkit-0.116.tar.gz..."
wget --no-check-certificate https://www.freedesktop.org/software/polkit/releases/polkit-0.116.tar.gz

# Unduh patch untuk Polkit 0.116
echo "Mengunduh patch untuk polkit-0.116..."
wget --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/9.0/polkit-0.116-fix_elogind_detection-1.patch

# Ekstrak file sumber
echo "Mengekstrak file sumber..."
tar -xzf polkit-0.116.tar.gz
cd polkit-0.116

# Terapkan patch
echo "Menerapkan patch..."
patch -Np1 -i ../polkit-0.116-fix_elogind_detection-1.patch

# Menjalankan autoreconf
echo "Menjalankan autoreconf..."
autoreconf -fi

# Membuat pengguna dan grup untuk polkitd
echo "Menambahkan grup dan pengguna untuk polkitd..."
sudo groupadd -fg 27 polkitd
sudo useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
     -g polkitd -s /bin/false polkitd

# Konfigurasi build
echo "Menyiapkan konfigurasi build..."
./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     \
            --with-os-type=LFS   \
            --enable-libsystemd-login=no

# Kompilasi Polkit
echo "Kompilasi Polkit 0.116..."
make

# Instalasi sebagai root
echo "Menginstal Polkit 0.116..."
sudo make install

# Instalasi info file
echo "Menyalin file info..."
sudo install -v -m644 polkitd.info /usr/share/info
sudo install-info --info-dir=/usr/share/info polkitd.info

# Membuat file konfigurasi PAM (jika dibangun dengan Linux PAM support)
echo "Menyiapkan konfigurasi PAM untuk Polkit..."
cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1

auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/polkit-1
EOF

# Pembersihan
echo "Membersihkan direktori sementara..."
cd /web1
rm -rf /web1/polkit-0.116

echo "Instalasi Polkit 0.116 selesai!"
