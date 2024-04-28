#!/usr/bin/env ksh

# Install and configure a Mail Server on OpenBSD. Curently tested
# on OpenBSD 7.5. I use this script as a "Startup Script" when
# intially installing the server, but you can manually run it if you wish.

# Patch new server install
pkg_add -u

# Install vim with python3 support
pkg_add vim-9.1.139-no_x11-python3

# Add alias for vim to .profile
echo '' >> ~/.profile
echo '#Added by preInstallMail.sh' >> ~/.profile
echo "alias vi='vim'" >> ~/.profile

# Patch the kernel and reboot the server
syspatch

reboot

# After rebooting you might have to patch the kernel again
# See postInstallMail.sh script comments
