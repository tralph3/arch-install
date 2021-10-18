#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

export ROOT_DEVICE=/dev/sdX    # replace with desired disk
export PASSWD=
export HOSTNAME=
export USERNAME=
export WIN_DEVICE=/dev/sdX     # leave empty if none
export STRG_DEVICE=/dev/sdX    # leave empty if none
export UEFI=                   # y/n

source definitions.sh

configure_pacman

if [ $UEFI == y ]; then
    partition_and_mount_uefi
elif [ $UEFI == n ]; then
    partition_and_mount_bios
else
    echo "Incorrect value for UEFI variable"
    exit
fi

install_base

cp definitions.sh /mnt

# all the following will be ran inside the chroot
cat << EOF | arch-chroot /mnt
source definitions.sh
configure_pacman
setup_network
prepare_system
setup_users
setup_gui
install_applications
enable_services
exit
EOF

reboot
