#!/bin/bash
sed -i 's/env python/&3/' src/psl-make-dafsa &&
./configure --prefix=/usr --disable-static       &&
make -j$(nproc)
make install
