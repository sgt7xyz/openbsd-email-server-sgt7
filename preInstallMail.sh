#!/bin/sh

#Install and configure a Mail Server on OpenBSD. Curently tested
#on OpenBSD 6.8. I use this script as a "Startup Script" when
#intially installing the server, but you can manually run it if you wish.

#Patch new server install
pkg_add -u

#Install vim with python3 support
pkg_add vim

syspatch

reboot

#After rebooting you might have to patch the kernel again
#See postInstallMail.sh script comments
