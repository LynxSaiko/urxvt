#!/bin/bash
wget --no-check-certificate https://lfs.it-privat.dk/patches/downloads/gst-plugins-base/gst-plugins-base-0.10.36-gcc_4_9_0_i686-1.patch
patch -Np1 -i gst-plugins-base-0.10.36-gcc_4_9_0_i686-1.patch
./configure --prefix=/usr --disable-static &&
make -j$(nproc)
make install
