#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

ROOT_DEVICE=/dev/sdX  # replace with desired disk
PASSWD=
HOSTNAME=
USERNAME=
WIN_DEVICE=/dev/sdX
STRG_DEVICE=/dev/sdX

source definitions.sh

partition_and_mount
install_base

cp definitions.sh /mnt

# all the following will be ran inside the chroot
cat << EOF | arch-chroot /mnt
source definitions.sh
setup_network
prepare_system
setup_users
setup_gui
install_applications
enable_services
exit
EOF

reboot
