#!/bin/bash


#############
# PRE-SETUP #
#############
setup_variables() {

    echo "\x1b[1;36m"
    # this is ASCII art
    base64 -d <<<"H4sIAAAAAAAAA1NQAIF4/Xh9GA1hIdgwGZioggI2eQiNUIsQ5VLAFEdWgdsGhAw2/TA+F8wpEC6y
YmSH4jMeFaM6nlKnIzyAxem4/IU95NE9iWotuseBxgMAqF41l90BAAA=" | gunzip
    echo "\x1b[0m"
    echo
    echo "Choose the device you want to install Arch Linux on:"
    echo "\x1b[1;31mThe chosen device will be completely erased and all its data will be lost"
    echo
    echo "\x1b[33m"
    # show the drives in yellow
    lsblk
    echo "\x1b[0m"
    echo
    echo
    PS3="Choose the root drive: "

    select drive in $(lsblk | sed '/\(^├\|^└\|^NAME\)/d' | cut -d " " -f 1)
    do
        if [ $drive ]; then
            export ROOT_DEVICE="/dev/$drive"
            break
        fi
    done

    PS3="Choose your Windows partition to setup dual-boot: "

    select drive in $(lsblk | sed '/\(^├\|^└\)/!d' | cut -d " " -f 1 | cut -c7-) "None"
    do
        if [ "$drive" = "None" ]; then
            unset WIN_DEVICE
            break
        fi

        if [ $drive ]; then
            export WIN_DEVICE="/dev/$drive"
            break
        fi
    done

    PS3="Choose an extra partition to use as Storage: "

    select drive in $(lsblk | sed '/\(^├\|^└\)/!d' | cut -d " " -f 1 | cut -c7-) "None"
    do
        if [ "$drive" = "None" ]; then
            unset STRG_DEVICE
            break
        fi

        if [ $drive ]; then
            export STRG_DEVICE="/dev/$drive"
            break
        fi
    done

    read "USR?Enter your username: "
    read -s "PASSWD?Enter your password: "
    echo ""
    read "HOSTNAME?Enter this machine's hostname: "

    echo "export USR=$USR" >> vars.sh
    echo "export PASSWD=$PASSWD" >> vars.sh
    echo "export HOSTNAME=$HOSTNAME" >> vars.sh

    PS3="Choose your desktop environment: "
    select de in "KDE" "GNOME"
    do
        if [ $de ]; then
            echo "DE=$\"$de\"" >> vars.sh
            break
        fi
    done

    print_summary
}

print_summary() {

    echo "Summary:"
    echo ""
    echo ""
    # set text to bold red
    echo "\x1b[1;33m"
    echo "The installer will erase all data on the \x1b[1;31m$ROOT_DEVICE\x1b[1;33m drive"
    # reset styling settings
    echo "\x1b[0m"

    if [ $STRG_DEVICE ]; then
        echo ""
        echo "It will use \x1b[1;33m$STRG_DEVICE\x1b[0m as a storage medium and mount it on \x1b[1;33m/mnt/Storage\x1b[0m"
    fi


    if [ $WIN_DEVICE ]; then
        echo ""
        echo "It will treat \x1b[1;33m$WIN_DEVICE\x1b[0m as a Windows partition and it will be mounted on \x1b[1;33m/mnt/Windows\x1b[0m"
    fi

    echo ""

    echo "Your username will be \x1b[1;33m$USR\x1b[0m and the machine's hostname is \x1b[1;33m$HOSTNAME\x1b[0m"

    read "ANS?Proceed with installation? [y/N]: "

    if [ "$ANS" != "y" ]; then
        exit
    fi
}

configure_pacman() {
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i 's/^#VerboseP/VerboseP/' /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
}


################
# PARTITIONING #
################
partition_and_mount() {

    if [ -d /sys/firmware/efi/efivars ]; then
        UEFI=y
        partition_and_mount_uefi
    else
        UEFI=n
        partition_and_mount_bios
    fi
}

partition_and_mount_uefi() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    cut -d " " -f 1 << EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
g           # gpt partition scheme
n           # new partition
            # partition number 1
            # start of sector
+512MB      # plus 512MB
n           # new parition
            # partition number 2
            # start of sector
            # end of sector
w           # write
EOL

    # partition formatting
    mkfs.fat -F 32 ${ROOT_DEVICE}1     # boot
    mkfs.ext4 ${ROOT_DEVICE}2 -L ROOT  # root

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

partition_and_mount_bios() {
    timedatectl set-ntp true # sync clock

    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    cut -d " " -f 1 << EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
n           # new partition
            # primary partition
            # partition number 1
            # start of sector
            # end of sector
w           # write
EOL

    # partition formatting
    mkfs.ext4 ${ROOT_DEVICE}1 -L ROOT  # root/boot

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


install_base() {
    pacstrap /mnt ${BASE[@]}
    reflector > /mnt/etc/pacman.d/mirrorlist
    genfstab -U /mnt >> /mnt/etc/fstab
}


###########
# NETWORK #
###########
setup_network() {
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

configure_locale() {
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}


########
# BASE #
########
prepare_system() {
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

install_cpu_ucode() {
    CPU=$(lscpu | awk '/Vendor ID:/ {print $3}')

    if [ "$CPU" == AuthenticAMD ]; then
        pacman --needed --noconfirm -S amd-ucode
    elif [ "$CPU" == GenuineIntel ]; then
        pacman --needed --noconfirm -S intel-ucode
    fi
}

configure_grub() {

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
    cd -

    # install theme
    mkdir -pv /boot/grub/themes
    mv /Grub-themes/xenlism-grub-arch-1080p/Xenlism-Arch /boot/grub/themes

    # enable OS_PROBER and set the theme
    echo -e '\nGRUB_DISABLE_OS_PROBER=false\nGRUB_THEME="/boot/grub/themes/Xenlism-Arch/theme.txt"' >> /etc/default/grub

    # clean up
    rm -rf /Grub-themes
}


#########
# USERS #
#########
setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games -s /bin/zsh ${USR}
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd ${USR}

    export USR_HOME=$(getent passwd ${USR} | cut -d\: -f6)

    # let wheel group use sudo
    sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
    # add insults to injury
    sed -i "s|@includedir /etc/sudoers.d|@includedir /etc/sudoers.d\n\nDefaults insults|" /etc/sudoers
}


#######
# GUI #
#######
setup_gui() {

    case $DE in

        KDE)
            DE=$KDE
            SERVICES+=('sddm')
            break
            ;;
        GNOME)
            DE=$GNOME
            SERVICES+=('gdm')
            break
            ;;
    esac

    pacman --needed --noconfirm -S ${DE[@]}
    detect_drivers
    pacman --needed --noconfirm -S ${GPU_DRIVERS[@]}
}

detect_drivers(){
    GPU=$(lspci | grep VGA | cut -d " " -f 5-)

    if [[ "${GPU}" == *"NVIDIA"* ]]; then
        GPU_DRIVERS+=('nvidia' 'nvidia-utils' 'lib32-nvidia-utils')
    elif [[ "${GPU}" == *"AMD"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'mesa-vdpau' 'lib32-mesa-vdpau'\
            'xf86-video-amdgpu' 'vulkan-radeon' 'lib32-vulkan-radeon'\
            'libva-mesa-driver' 'lib32-libva-mesa-driver')
    elif [[ "${GPU}" == *"Intel"* ]]; then
        GPU_DRIVERS+=('mesa' 'lib32-mesa' 'vulkan-intel')
    fi

    echo "${GPU_DRIVERS[@]}"
}


#################
# CUSTOMIZATION #
#################
install_applications() {
    pacman --needed --noconfirm -S ${APPS[@]}
    install_paru

    # let the regular user use sudo without password for these commands
    sed -i "s/^%wheel ALL=(ALL) ALL/# %wheel ALL=(ALL) ALL/" /etc/sudoers
    sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

    sudo -u ${USR} paru --needed --noconfirm -S ${AUR[@]}
    install_dotfiles
    install_powerlevel10k
    configure_nvim

    # revert the changes
    sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
    sed -i "s/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
}

install_paru() {
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

install_dotfiles() {
    git clone https://github.com/tralph3/.dotfiles ${USR_HOME}/.dotfiles
    chmod +x ${USR_HOME}/.dotfiles/install.sh
    chown -R ${USR} ${USR_HOME}
    chgrp -R ${USR} ${USR_HOME}
    sudo -u ${USR} ${USR_HOME}/.dotfiles/install.sh
}

install_powerlevel10k() {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${USR_HOME}/.config/powerlevel10k
    chown -R ${USR} ${USR_HOME}
    chgrp -R ${USR} ${USR_HOME}
}

configure_nvim() {
    # init.vim installs plug and plugins automatically if it's not there
    sudo -u ${USR} nvim

    sudo -u ${USR} mkdir -vp ${USR_HOME}/.config/coc/extensions
    cd ${USR_HOME}/.config/coc/extensions
    sudo -u ${USR} echo '{"dependencies":{}}'> package.json

    # install extensions
    sudo -u ${USR} npm install ${COC[@]} --global-style --ignore-scripts\
        --no-bin-links --no-package-lock --only=prod

    # return to previous directory
    cd -
}


############
# SERVICES #
############
enable_services() {
    for service in $SERVICES
    do
        systemctl enable $service
    done
}

