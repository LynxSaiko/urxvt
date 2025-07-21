#!/bin/bash

# Direktori kerja untuk instalasi elogind
mkdir -p /web1/elogind-install
cd /web1/elogind-install

# Unduh sumber elogind
echo "Mengunduh sumber elogind..."
wget --no-check-certificate https://github.com/elogind/elogind/archive/v241.3/elogind-241.3.tar.gz

# Ekstrak file sumber
echo "Mengekstrak file sumber..."
tar -xzf elogind-241.3.tar.gz
cd elogind-241.3

# Membuat direktori build
mkdir build && cd build

# Menjalankan konfigurasi menggunakan Meson
echo "Menyiapkan konfigurasi dengan Meson..."
meson --prefix=/usr                    \
      --sysconfdir=/etc                \
      --localstatedir=/var             \
      -Dcgroup-controller=elogind      \
      -Ddbuspolicydir=/etc/dbus-1/system.d \
      ..

# Membangun menggunakan Ninja
echo "Membangun menggunakan Ninja..."
ninja

# Instalasi elogind
echo "Menginstal elogind..."
sudo ninja install

# Membuat symbolic link untuk kompatibilitas dengan systemd
echo "Membuat symbolic links..."
sudo ln -sfv libelogind.pc /usr/lib/pkgconfig/libsystemd.pc
sudo ln -sfvn elogind /usr/include/systemd

# Menginstal skrip boot untuk memulai elogind saat boot
echo "Menginstal skrip boot..."
sudo make install-elogind

# Mengonfigurasi PAM untuk elogind
echo "Menambahkan konfigurasi PAM..."
cat >> /etc/pam.d/system-session << "EOF"
# Begin elogind addition
session  required    pam_loginuid.so
session  optional    pam_elogind.so
# End elogind addition
EOF

cat > /etc/pam.d/elogind-user << "EOF"
# Begin /etc/pam.d/elogind-user
account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_unix.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_elogind.so

auth     required    pam_deny.so
password required    pam_deny.so
# End /etc/pam.d/elogind-user
EOF

# Pembersihan direktori sementara
echo "Membersihkan direktori sementara..."
cd /web1
rm -rf /web1/elogind-install

echo "Instalasi elogind selesai!"
