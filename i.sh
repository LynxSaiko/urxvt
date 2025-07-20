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

	cd /download1
	rm -rf $package_name
}
cd /download1

echo "[*] Build Atk [*]"
wget https://download.gnome.org/sources/atk/2.38/atk-2.38.0.tar.xz
wget https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/2.2/shared-mime-info-2.2.tar.gz
wget https://anduin.linuxfromscratch.org/BLFS/xdgmime/xdgmime.tar.xz
wget https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.9.tar.xz
wget https://download.gnome.org/sources/gtk+/2.24/gtk+-2.24.33.tar.xz
