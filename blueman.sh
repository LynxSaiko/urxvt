#!/bin/bash
patch -Np1 -i ../bluez-5.65-obexd_without_systemd-1.patch
./configure --prefix=/usr         \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --enable-library      \
            --disable-manpages    \
            --disable-systemd     &&
make
make install &&
ln -svf ../libexec/bluetooth/bluetoothd /usr/sbin
install -v -dm755 /etc/bluetooth &&
install -v -m644 src/main.conf /etc/bluetooth/main.conf
cat > /etc/bluetooth/rfcomm.conf << "EOF"
# Start rfcomm.conf
# Set up the RFCOMM configuration of the Bluetooth subsystem in the Linux kernel.
# Use one line per command
# See the rfcomm man page for options


# End of rfcomm.conf
EOF
cat > /etc/bluetooth/uart.conf << "EOF"
# Start uart.conf
# Attach serial devices via UART HCI to BlueZ stack
# Use one line per device
# See the hciattach man page for options

# End of uart.conf
EOF
wget --no-check-certificate https://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20220722.tar.xz

make install-bluetooth
