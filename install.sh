#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

ROOT_DEVICE=/dev/sdX  # replace with desired disk
PASSWD=
HOSTNAME=


function pre_setup() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    fdisk --wipe always $ROOT_DEVICE << FDISK_CMDS
g
n


+512MB
n



w
FDISK_CMDS

    # partition formatting
    mkfs.fat -F 32 ${ROOT_DEVICE}1 # boot
    mkfs.ext4 ${ROOT_DEVICE}2      # root

    # mount partitions
    mount ${ROOT_DEVICE}2 /mnt
    mkdir -p /mnt/boot
    mount ${ROOT_DEVICE}1 /mnt/boot

    # get mirrors
    reflector > /etc/pacman.d/mirrorlist
    cp -f pacman.conf /etc/pacman.conf
}

function install_base() {
    pacstrap /mnt base linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
    cp -f locale.gen /mnt/etc/locale.gen
    cp -f pacman.conf /mnt/etc/pacman.conf
    arch-chroot /mnt
}

function set_up_network() {
    # time
    ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
    hwclock --systohc

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "${HOSTNAME}" > /etc/hostname
    cat >> /etc/hosts <<EOL

127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOL
    echo ${PASSWD} | passwd --stdin
}

function prepare_system() {
    pacman -Syu
}
