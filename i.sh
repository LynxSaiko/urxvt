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
begin atk-2.38.0 tar.xz
cd atk-2.38.0
mkdir build &&
cd    build &&

meson --prefix=/usr --buildtype=release .. &&
ninja
finish 

echo "[*] Build Shared Mime [*]"
begin shared-mime-info-2.2 tar.xz
cd shared-mime-info-2.2
tar -xf xdgmime.tar.xz &&
make -C xdgmime
mkdir build &&
cd    build &&

meson --prefix=/usr --buildtype=release -Dupdate-mimedb=true .. &&
ninja
ninja install
finish

echo "[*] Build Gdk Pixbuf [*]"
begin gdk-pixbuf-2.42.9 tar.xz
cd gdk-pixbuf-2.42.9
mkdir build &&
cd    build &&
meson --prefix=/usr --buildtype=release --wrap-mode=nofallback .. &&
ninja
finish


echo "[*] Build Gtk+2 [*]"
begin gtk+-2.24.33 tar.xz
cd tk+-2.24.33
sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
    -i docs/{faq,tutorial}/Makefile.in      &&

./configure --prefix=/usr --sysconfdir=/etc &&

make
make install
gtk-query-immodules-2.0 --update-cache
cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF
finish
