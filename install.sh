#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

export ROOT_DEVICE=/dev/sdX    # Drive were Arch will be installed
export PASSWD=
export HOSTNAME=
export USERNAME=
export WIN_DEVICE=/dev/sdX     # For Windows partition (leave empty if none)
export STRG_DEVICE=/dev/sdX    # For secondary drive (leave empty if none)
export UEFI=y                  # y/n
export GPU=amd                 # amd/nvidia/intel

export BASE=(
'base'
'linux'
'linux-firmware'
)

export BASE_APPS=(
'grub'
'efibootmgr'
'networkmanager'
'network-manager-applet'
'openssh'
'base-devel'
'linux-headers'
'dialog'
'os-prober'
'mtools'
'dosfstools'
'git'
'usbutils'
'xdg-user-dirs'
'xdg-desktop-portal-kde'
'wget'
'reflector'
)

export APPS=(
'firefox'
'lutris'
'steam'
'steam-native-runtime'
'discord'
'android-tools'
'unrar'
'unzip'
'nano'
'neovim'
'vim'
'sudo'
'exa'
'mlocate'
'cronie'
'cups'
'bc'
'npm'
'mpv'
'gimp'
'htop'
'gamemode'
'wine'
'wine-mono'
'wine-gecko'
'winetricks'
'zenity'
'zip'
'numlockx'
)

export AUR=(
'proton-ge-custom-bin'
'mangohud'
)

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

cp -vf ~/arch-install/definitions.sh /mnt

# all the following will be ran inside the chroot
cat << EOF | arch-chroot /mnt
source definitions.sh
pacman --noconfirm -Sy python
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
