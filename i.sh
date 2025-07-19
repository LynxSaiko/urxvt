#!/bin/bash
package_name=""
package_ext=""

begin() {
	package_name=$1
	package_ext=$2

	echo "Starting build of $package_name at $(date)"

	tar xf $package_name.$package_ext
	cd $package_name
}

finish() {
	echo "Finishing build of $package_name at $(date)"

	cd $LFS/sources
	rm -rf $package_name
}
cd /home/leakos/download
wget https://download.gnome.org/sources/cairo/1.17/cairo-1.17.6.tar.xz
begin cairo-1.17.6 tar.xz
cd cairo-1.17.6
sed 's/PTR/void */' -i util/cairo-trace/lookup-symbol.c
sed -e "/@prefix@/a exec_prefix=@exec_prefix@" \
    -i util/cairo-script/cairo-script-interpreter.pc.in

./configure --prefix=/usr    \
            --disable-static \
            --enable-tee &&
make -j$(nproc)
make install

