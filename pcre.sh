#!/bin/sh
wget --no-check-certificate https://ftp.exim.org/pub/pcre/pcre-8.41.tar.bz2
tar -xf pcre-8.45.tar.*  # sesuaikan ekstensi
cd pcre-8.45
./configure --prefix=/usr \
  --enable-unicode-properties \
  --enable-pcre16 \
  --enable-pcre32 \
  --enable-pcregrep-libz \
  --enable-pcregrep-libbz2 \
  --enable-pcretest-libreadline \
  --disable-static
make
make install
