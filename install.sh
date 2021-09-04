#!/bin/bash
# arch installation script, KDE, GPT partition scheme, xorg

ROOT_DEVICE=/dev/sdX  # replace with desired disk
PASSWD=
HOSTNAME=
USERNAME=


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
    mkfs.fat -F32 ${ROOT_DEVICE}1 # boot
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
    # install basic utilities
    pacman --noconfirm -Syu grub efibootmgr networkmanager network-manager-applet openssh base-devel linux-headers dialog os-prober mtools dosfstools git nano neovim vim sudo
    
    # install grub
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    grub-mkconfig -o /boot/grub/grub.cfg
}

function setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games ${USERNAME}
    echo ${PASSWD} | passwd ${USERNAME} --stdin
}

function setup_gui() {
    pacman -S plasma kde-applications firefox lutris steam-native nvidia nvidia-utils
}

function enable_services() {
    systemctl enable NetworkManager
    systemctl enable sshd
    systemctl enable sddm
}
