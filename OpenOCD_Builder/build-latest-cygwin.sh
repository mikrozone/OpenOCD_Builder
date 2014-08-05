#!/bin/sh
#
# Build script to cross-compile OpenOCD with MinGW.
#
# CygWin must have installed these packages: wget, tar, gawk, xz, bzip2
#
# script v0.1, edizontn@gmail.com, www.mikrozone.eu


echo "*****************************************************************"
echo "      Script for build latest OpenOCD for Win_32 under MinGw     "
echo "*****************************************************************"
echo "Downloading package manager ..."
echo " "
wget "https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg" apt-cyg     
chmod +x apt-cyg                                                                           
mv apt-cyg /usr/local/bin                                                                  

echo "*****************************************************************"
echo "Installing required packages ..."
echo " "
#apt-get install p7zip-full curl git mingw-w64 libtool automake texinfo
apt-cyg install bzip2 curl unzip git mingw64-x86_64-gcc mingw64-x86_64-gcc-core mingw64-x86_64-pkg-config mingw64-x86_64-headers mt libtool automake texinfo  

echo "Downloading and installing 7zip ..."
apt-cyg install make gcc-g++ binutils findutils 
curl -L "http://sourceforge.net/projects/p7zip/files/latest/download?source=files" -o P7ZIP.tar.bz2
mkdir p7zip 
tar -xf P7ZIP.tar.bz2 -C p7zip 
cd p7zip/* 
make
./install.sh                
cd .. 
cd ..

echo "*****************************************************************"
echo "Downloading OpenOCD source ..."
echo " "
mkdir -p openocd-src
#cd openocd-src
git clone "git://git.code.sf.net/p/openocd/code" openocd-src 
#curl -L "https://sourceforge.net/projects/openocd/files/latest/download?source=files" -o openocd-src.tar.bz2 
 
echo "*****************************************************************"
echo "Downloading D2XX -v 2.10.00..."
echo " "
curl -L "http://www.ftdichip.com/Drivers/CDM/CDM%20v2.10.00%20WHQL%20Certified.zip" -o CDM_21000.zip  
#curl -L "http://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx1.1.12.tar.gz" -o CDM_21000.zip

echo "*****************************************************************"
echo "Downloading latest libusb-win32 ..."
echo " "
curl -L "https://sourceforge.net/projects/libusb-win32/files/latest/download?source=files" -o libusb-win32-bin-latest.zip
 
echo "*****************************************************************"
echo "Downloading latest libusbx-latest-win ..."
echo " "
mkdir -p libusbx-latest-win
curl -L "http://sourceforge.net/projects/libusbx/files/releases/1.0.18/binaries/libusbx-1.0.18-win.7z/download" -o libusbx-latest-win/libusbx-latest-win.7z

echo "*****************************************************************"
echo "Downloading latest hidapi ..."
echo " "
mkdir hidapi
cd hidapi
git clone "https://github.com/signal11/hidapi" hidapi
cd ..

echo "*****************************************************************"
echo "Unpacking D2XX..."
echo " "
unzip -uo -qq CDM_21000.zip -d CDM_latest
 
echo "*****************************************************************"
echo "Unpacking libusb-win32..."
echo " "
unzip -uo -qq libusb-win32-bin-latest.zip -d libusb-win32-bin-latest
 
echo "*****************************************************************"
echo "Unpacking libusbx-latest-win..."
echo " "
cd libusbx-latest-win
#mkdir libusbx-latest-win
7za x libusbx-latest-win.7z
rm libusbx-latest-win.7z
#tar -xf libusbx-latest-win.tar.bz2  -C /libusbx-latest-win
cd ..

mkdir -p /usr/i686-w64-mingw32/include
echo "*****************************************************************"
echo "Installing D2XX..."
echo " "
cp CDM_latest/ftd2xx.h /usr/i686-w64-mingw32/include
cp CDM_latest/i386/ftd2xx.lib /usr/i686-w64-mingw32/lib/ftd2xx.a

echo "*****************************************************************" 
echo "Installing libusb-win32..."
echo " "
cp libusb-win32-bin-latest/*/lib/gcc/libusb.a /usr/i686-w64-mingw32/lib
cp libusb-win32-bin-latest/*/include/lusb0_usb.h /usr/i686-w64-mingw32/include
#cp libusb-win32-bin-latest/*/include/usb.h /usr/i686-w64-mingw32/include
ln -s -f /usr/i686-w64-mingw32/include/lusb0_usb.h /usr/i686-w64-mingw32/include/usb.h 

echo "*****************************************************************" 
echo "Installing libusbx-latest-win..."
echo " "
cp libusbx-latest-win/MinGW32/dll/* /usr/i686-w64-mingw32/lib
cp libusbx-latest-win/MinGW32/static/* /usr/i686-w64-mingw32/lib
#cp -r libusbx-latest-win/include/libusbx-1.0 /usr/i686-w64-mingw32/include/libusbx-1.0
cp -r libusbx-latest-win/include/libusbx-1.0 /usr/i686-w64-mingw32/include/libusbx-1.0
#ln -f -s /usr/i686-w64-mingw32/include/libusbx-1.0 /usr/i686-w64-mingw32/include/libusb-1.0
###### ln -f -s /usr/include/libusbx-1.0 /usr/i686-w64-mingw32/include/libusb-1.0


# maybe in future.....
#echo "*****************************************************************"
#echo "Installing hidapi..."
#echo " "
#apt-cyg install libusb1.0 libusb1.0-devel autotools-dev autoconf libtool automake gettext
#cd hidapi/*
#./bootstrap
#./configure
#make
#make install
#cd ..
#cd ..
# ln -s /usr/local/lib/libhidapi-hidraw.so.0 /usr/lib/libhidapi-hidraw.so.0
#ln -s /usr/local/lib/libhidapi.a /usr/lib/libhidapi.a

echo "*****************************************************************"
echo "Installing openocd..."
echo " "
cd openocd-src
#cd openocd-src/*
./bootstrap
cd ..

echo "*****************************************************************"
echo "Configuring OpenOCD..."
echo " "
mkdir -p openocd-build
cd openocd-build
.././openocd-src/configure --enable-maintainer-mode --build=i686-pc-cygwin --host=i686-w64-mingw32 --disable-werror --disable-shared  --enable-presto_ftd2xx --enable-ftdi --with-ftd2xx-win32-zipdir="../CDM_latest" --prefix=$(pwd)/../openocd-install 
#./configure --enable-maintainer-mode --disable-werror --disable-shared --with-ftd2xx-win32-zipdir=/tmp/ftd2xx --build=i686-pc-cygwin --host=i686-pc-mingw32 --enable-parport --enable-openjtag_ftd2xx --enable-armjtagew --enable-rlink --enable-usbprog --enable-vsllink --enable-aice --enable-opendous --enable-osbdm --enable-jlink --enable-usb-blaster-2 --enable-ulink --enable-ti-icdi --enable-stlink --enable-legacy-ft2232_ftd2xx --includedir=/usr/include/libusb-1.0/libusb.h
#./openocd-src/*/configure --enable-maintainer-mode --build=i686-pc-cygwin --host=i586-mingw32msvc --disable-werror --disable-shared --enable-ftdi --with-ftd2xx-win32-zipdir=../CDM_latest --prefix=$(pwd)/../openocd-install


echo "*****************************************************************"
echo "Building and installing OpenOCD..."
echo " "
make
mkdir -p ../openocd-install 
make
make install
cd ..
 
cd openocd-install
cp ../libusbx-latest-win/MinGW32/dll/*.dll ./bin
cp ../CDM_latest/i386/ftd2xx.dll ./bin
cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libwinpthread-1.dll ./bin 
cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libgcc_s_sjlj-1.dll ./bin
cp ../libusb-win32-bin-latest/*/bin/x86/*.dll ./bin  

cd ..
 
echo "*****************************************************************"
echo "Cleaning OpenOCD install directory..."
echo " "
cp -r share/openocd/contrib contrib
cp -r share/openocd/scripts scripts
rm -rf share >> /dev/null
rm -rf lib >> /dev/null
rm *.zip >> /dev/null
rm *.html >> /dev/null
rm *.bz2 >> /dev/null
 
cd ..
 
echo "*****************************************************************"
echo "Copying OpenOCD checkout information to install directory..."
echo " "
cp openocd-src/NEWS* openocd-install
cp openocd-src/BUGS openocd-install
#cp $0 openocd-install

echo "*****************************************************************"
echo "*****************************************************************"
echo "*****************************************************************"
echo "  Build done. Output you can find in 'openocd-install' folder.   "
echo "*****************************************************************"
echo "*****************************************************************"
echo "*****************************************************************"
