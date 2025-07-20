#!/bin/bash

sed -i  -e '/YYLEX_PARAM/d'                                       \
        -e '/parse-param.*scanner/i %lex-param { void *scanner }' \
            gst/parse/grammar.y &&

./configure --prefix=/usr \
            --disable-static &&
make -j$(nproc)
make install
