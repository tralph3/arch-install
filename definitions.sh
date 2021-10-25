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
    fdisk --wipe always --wipe-partitions always $ROOT_DEVICE << FDISK_CMDS
g
n



+512MB
n




w
FDISK_CMDS

    # partition formatting
    mkfs.fat -F 32 ${ROOT_DEVICE}1  # boot
    mkfs.ext4 ${ROOT_DEVICE}2      # root

    # mount partitions
    mkdir -pv /mnt
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
}

function install_base() {
    pacstrap /mnt $BASE
    genfstab -U /mnt >> /mnt/etc/fstab
}

function partition_and_mount_bios() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    fdisk --wipe always --wipe-partitions always $ROOT_DEVICE << FDISK_CMDS
n




w
FDISK_CMDS

    # partition formatting
    mkfs.ext4 ${ROOT_DEVICE}1      # root/boot

    # mount partitions
    mkdir -pv /mnt
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
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd
}

function install_cpu_ucode() {
    CPU=$(lscpu | awk '/Vendor ID:/ {print $3}')

    if [ "$CPU" == AuthenticAMD ]; then
        pacman --noconfirm -S amd-ucode
    elif [ "$CPU" == GenuineIntel ]; then
        pacman --noconfirm -S intel-ucode
    fi
}

function configure_grub() {

# get theme
git clone \
  --depth 1  \
  --filter=blob:none  \
  --sparse \
  https://github.com/xenlism/Grub-themes \
;
cd Grub-themes
git sparse-checkout init --cone
git sparse-checkout set xenlism-grub-arch-1080p

# install theme
mkdir -pv /boot/grub/themes
mv xenlism-grub-arch-1080p/Xenlism-Arch /boot/grub/themes

# enable OS_PROBER and set the theme
echo -e '\nGRUB_DISABLE_OS_PROBER=false\nGRUB_THEME="/boot/grub/themes/Xenlism-Arch/theme.txt"' >> /etc/default/grub
}

function prepare_system() {
    # install basic utilities
    pacman --noconfirm --needed -Syu $BASE_APPS

    install_cpu_ucode

    # install grub
    if [ "$UEFI" == y ]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    elif [ "$UEFI" == n ]; then
        grub-install --target=i386-pc $ROOT_DEVICE
    fi

    configure_grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

function setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games -s /bin/zsh ${USERNAME}
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd ${USERNAME}

    # let wheel group use sudo
    replace "# %wheel ALL=(ALL) ALL\n" "%wheel ALL=(ALL) ALL\n" /etc/sudoers
    # add insults to the mix
    replace "@includedir /etc/sudoers.d" "@includedir /etc/sudoers.d\n\nDefaults insults" /etc/sudoers
}

function setup_gui() {
    pacman --noconfirm -S plasma kde-applications
}

function install_paru() {
    cd /home/${USERNAME}/
    git clone https://aur.archlinux.org/paru-bin.git paru
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
    cd /
}

function install_applications() {
    pacman --noconfirm -S $APPS
    install_paru
    paru --noconfirm -S $AUR
    configure_terminal
}

function configure_terminal() {
    pacman --noconfirm -S zsh zsh-autosuggestions zsh-syntax-highlighting
}

function enable_services() {
    systemctl enable NetworkManager
    systemctl enable sshd
    systemctl enable sddm
    systemctl enable cups
    systemctl enable cronie
}

function reboot {
    umount -R /mnt
    reboot
}

