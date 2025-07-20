#!/bin/bash
wget --no-check-certificate https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/gst-plugins-base/files/gst-plugins-base-0.10.36-glib-2.32.patch?revision=1.2 -O glib2.32.patch
patch -p1 < glib2.32.patch
./configure --prefix=/usr --disable-static &&
make -j$(nproc)
make install
