#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

export ROOT_DEVICE=/dev/sdX    # Drive were Arch will be installed
export PASSWD=
export HOSTNAME=
export USERNAME=
export WIN_DEVICE=/dev/sdX     # For Windows partition (leave empty if none)
export STRG_DEVICE=/dev/sdX    # For secondary drive (leave empty if none)
export UEFI=y                  # y/n

source definitions.sh
source packages.sh

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

cat packages.sh definitions.sh > /mnt/definitions.sh

# all the following will be ran inside the chroot
cat << EOF | arch-chroot /mnt
source definitions.sh
configure_pacman
setup_network
prepare_system
enable_services
setup_users
setup_de
install_applications
exit
EOF

# clean up
rm -fv /mnt/definitions.sh
umount -R /mnt
reboot
