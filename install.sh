#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

ROOT_DEVICE=/dev/sdX  # replace with desired disk
PASSWD=
HOSTNAME=
USERNAME=
WIN_DEVICE=/dev/sdX
STRG_DEVICE=/dev/sdX

source definitions.sh

pre_setup
install_base

# all the following will be ran inside the chroot
cat << EOF | arch-chroot /mnt
setup_network
prepare_system
setup_users
setup_gui
enable_services
EOF

reboot
