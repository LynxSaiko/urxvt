#!/bin/bash
./configure --prefix=/usr --datadir=/usr/share/hwdata &&
make
make install
install -dm755 /usr/share/hwdata/ &&
wget --no-check-certificate http://www.linux-usb.org/usb.ids -O /usr/share/hwdata/usb.ids
cat > /etc/cron.weekly/update-usbids.sh << "EOF" &&
#!/bin/bash
/usr/bin/wget http://www.linux-usb.org/usb.ids -O /usr/share/hwdata/usb.ids
EOF
chmod 754 /etc/cron.weekly/update-usbids.sh
