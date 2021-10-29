#!/bin/bash

function configure_pacman() {
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i 's/^#VerboseP/VerboseP/' /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
}

function configure_locale() {
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function partition_and_mount_uefi() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
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

function configure_nvim() {
    # init.vim installs plug and plugins automaitcally if it's not there
    sudo -u ${USERNAME} nvim

    sudo -u ${USERNAME} mkdir -vp ${USR_HOME}/.config/coc/extensions
    cd ${USR_HOME}/.config/coc/extensions
    sudo -u ${USERNAME} echo '{"dependencies":{}}'> package.json

    # install extensions
    sudo -u ${USERNAME} npm install ${COC[@]} --global-style --ignore-scripts\
        --no-bin-links --no-package-lock --only=prod

    # return to previous directory
    cd -
}

function install_base() {
    pacstrap /mnt ${BASE[@]}
    genfstab -U /mnt >> /mnt/etc/fstab
}

function partition_and_mount_bios() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
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
        pacman --needed --noconfirm -S amd-ucode
    elif [ "$CPU" == GenuineIntel ]; then
        pacman --needed --noconfirm -S intel-ucode
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

    # clean up
    rm -rf /Grub-themes
}

function prepare_system() {
    # install basic utilities
    pacman --noconfirm --needed -Syu ${BASE_APPS[@]}

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

function enable_services() {
    sudo -u ${USERNAME} systemctl enable NetworkManager
    sudo -u ${USERNAME} systemctl enable sshd
    sudo -u ${USERNAME} systemctl enable sddm
    sudo -u ${USERNAME} systemctl enable cups
    sudo -u ${USERNAME} systemctl enable cronie
}

function setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games -s /bin/zsh ${USERNAME}
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd ${USERNAME}

    export USR_HOME=$(getent passwd ${USERNAME} | cut -d\: -f6)

    # let wheel group use sudo
    sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
    # add insults to injury
    sed -i "s|@includedir /etc/sudoers.d|@includedir /etc/sudoers.d\n\nDefaults insults|" /etc/sudoers
}

function detect_drivers(){
    GPU=$(lspci | grep VGA | cut -d " " -f 5-)

    if [[ "${GPU}" == *"NVIDIA"* ]]; then
        GPU_DRIVERS+=('nvidia' 'nvidia-utils' 'lib32-nvidia-utils')
    elif [[ "${GPU}" == *"AMD"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'mesa-vdpau' 'lib32-mesa-vdpau' 'xf86-video-amdgpu' 'vulkan-radeon' 'lib32-vulkan-radeon' 'libva-mesa-driver' 'lib32-libva-mesa-driver')
    elif [[ "${GPU}" == *"Intel"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'vulkan-intel')
    fi

    echo "${GPU_DRIVERS[@]}"
}

function setup_de() {
    pacman --needed --noconfirm -S ${KDE[@]}
    detect_drivers
    pacman --needed --noconfirm -S ${GPU_DRIVERS[@]}
}

function install_paru() {
    # use build directory to intall pary as "nobody" user
    # change the directory's group to "nobody" and make it sticky
    # so that all files within get the same properties
    mkdir /home/build
    cd /home/build
    chgrp nobody /home/build
    chmod g+ws /home/build
    setfacl -m u::rwx,g::rwx /home/build
    setfacl -d --set u::rwx,g::rwx,o::- /home/build

    # clone the repo
    git clone https://aur.archlinux.org/paru-bin.git paru
    cd paru

    # make the package as "nobody"
    sudo -u nobody makepkg

    # install the package as root
    pacman --noconfirm -U paru-bin*.zst

    # clean up
    cd
    rm -rf /home/build
}

function install_applications() {
    pacman --needed --noconfirm -S ${APPS[@]}
    install_paru

    # let the regular user use sudo without password for these commands
    sed -i "s/^%wheel ALL=(ALL) ALL/# %wheel ALL=(ALL) ALL/" /etc/sudoers
    sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

    sudo -u ${USERNAME} paru --needed --noconfirm -S ${AUR[@]}
    install_dotfiles
    install_powerlevel10k
    configure_kde
    configure_nvim
    enable_services

    # revert the changes
    sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
    sed -i "s/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
}

function install_dotfiles() {
    git clone https://github.com/tralph3/.dotfiles ${USR_HOME}/.dotfiles
    chmod +x ${USR_HOME}/.dotfiles/install.sh
    chown -R ${USERNAME} ${USR_HOME}
    chgrp -R ${USERNAME} ${USR_HOME}
    sudo -u ${USERNAME} ${USR_HOME}/.dotfiles/install.sh
}

function configure_kde() {
    sudo -u ${USERNAME} konsave -i ${USR_HOME}/.dotfiles/tralph3.knsv
    sudo -u ${USERNAME} konsave -a tralph3
}

function install_powerlevel10k() {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${USR_HOME}/.config/powerlevel10k
    chown -R ${USERNAME} ${USR_HOME}
    chgrp -R ${USERNAME} ${USR_HOME}
}

