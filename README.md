OpenOCD_Builder
===============

script for download and build of the OpenOCD.exe for win32 under CygWin.

Usage:
1. install cygwin
2. add a wget, tar, gawk, xz, bzip2 packages
3. run build-latest-cygwin.sh

Script will automaitcally install all additionally needed packages, download latest required libraries, start a compile and make binary files for win32.

v0.1.0  05.08.2014 - initial release. tested with Olimex ARM-USB-OCD


ToDo: 
- add a check of installed packages before download and install again
- test, test, test, ....
