#!/bin/bash

function uncomment() {

    # I'm not proud of this but using sed has proven to be a nightmare
    python - <<EOL
next_line = $3
found = False
with open("$2", 'r') as file:
    data = file.readlines()

for i, line in enumerate(data):
    if "$1" == line or found:
        data[i] = line[1:]
        if found:
            break
        if next_line:
            found = True


with open("$2", 'w') as file:
    file.writelines(data)
EOL
}

function replace() {

    # I'm not proud of this but using sed has proven to be a nightmare
    python - <<EOL
with open("$3", 'r') as file:
    data = file.readlines()

for i, line in enumerate(data):
    if "$1" == line:
        data[i] = "$2"
        break

with open("$3", 'w') as file:
    file.writelines(data)
EOL
}

function configure_pacman() {
    uncomment '#Color\n' /etc/pacman.conf False
    uncomment '#VerbosePkgLists\n' /etc/pacman.conf False
    uncomment '#[multilib]\n' /etc/pacman.conf True
    replace '#ParallelDownloads = 5\n' 'ParallelDownloads = 10\nILoveCandy\n' /etc/pacman.conf
}

function configure_locale() {
    uncomment '#en_US.UTF-8 UTF-8' /etc/locale.gen False
    uncomment '#es_AR.UTF-8 UTF-8' /etc/locale.gen False

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function partition_and_mount_uefi() {
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

    mkdir -pv /mnt/boot
    mount ${ROOT_DEVICE}1 /mnt/boot

    if [ $STRG_DEVICE ]; then
        mkdir -pv /mnt/mnt/Storage
        mount ${STRG_DEVICE} /mnt/mnt/Storage
    fi

    if [ $WIN_DEVICE ]; then
        mkdir -pv /mnt/mnt/Windows
        mount ${WIN_DEVICE} /mnt/mnt/Windows
    fi

    # get mirrors
    reflector > /etc/pacman.d/mirrorlist
    cp -vf pacman.conf /etc/pacman.conf
}

function install_base() {
    pacstrap /mnt base linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
}

function partition_and_mount_bios() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    fdisk --wipe always $ROOT_DEVICE << FDISK_CMDS
n



w
FDISK_CMDS

    # partition formatting
    mkfs.ext4 ${ROOT_DEVICE}1      # root/boot

    # mount partitions
    mount ${ROOT_DEVICE}1 /mnt

    if [ $STRG_DEVICE ]; then
        mkdir -pv /mnt/mnt/Storage
        mount ${STRG_DEVICE} /mnt/mnt/Storage
    fi

    if [ $WIN_DEVICE ]; then
        mkdir -pv /mnt/mnt/Windows
        mount ${WIN_DEVICE} /mnt/mnt/Windows
    fi

    # get mirrors
    reflector > /etc/pacman.d/mirrorlist
    cp -vf pacman.conf /etc/pacman.conf
}

function setup_network() {
    # time
    ln -sfv /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
    hwclock --systohc

    configure_locale

    echo "${HOSTNAME}" > /etc/hostname

    cat >> /etc/hosts <<EOL
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOL
    echo -e "${PASSWD}\n${PASSWD}" | passwd
}

function prepare_system() {
    # install basic utilities
    pacman --noconfirm -Syu grub efibootmgr networkmanager \
        network-manager-applet openssh base-devel linux-headers dialog \
        os-prober mtools dosfstools git

    # install grub
    if [ "$UEFI" == y ]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    elif [ "$UEFI" == n ]; then
        grub-install --target=i386-pc $ROOT_DEVICE
    fi
    grub-mkconfig -o /boot/grub/grub.cfg
}

function setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games ${USERNAME}
    echo -e ${PASSWD} | passwd ${USERNAME}
    replace "# %wheel ALL=(ALL) ALL\n" "%wheel ALL=(ALL) ALL\n" /etc/sudoers
    replace "@includedir /etc/sudoers.d" "@includedir /etc/sudoers.d\n\nDefaults insults" /etc/sudoers
}

function setup_gui() {
    pacman --noconfirm -S plasma kde-applications
}

function install_applications() {
    pacman --noconfirm -S firefox lutris steam-native nvidia nvidia-utils \
        discord android-tools unrar nano neovim vim sudo
}

function enable_services() {
    systemctl enable NetworkManager
    systemctl enable sshd
    systemctl enable sddm
}

function reboot {
    umount -R /mnt
    reboot
}

