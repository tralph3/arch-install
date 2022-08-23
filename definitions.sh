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
    echo "\x1b[33m"
    # show the drives in yellow
    lsblk
    echo "\x1b[0m"
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
    while
        echo "\x1b[33m"
        read -s "PASSWD?Enter your password: "
        echo ""
        read -s "CONF_PASSWD?Re-enter your password: "
        echo "\x1b[31m"
        [ "$PASSWD" != "$CONF_PASSWD" ]
    do echo "Passwords don't match"; done

    echo "\x1b[32mPasswords match\x1b[0m"
    echo ""

    read "HOSTNAME?Enter this machine's hostname: "

    PS3="Do you want to install applications for gaming?: "
    select GAMING in "Yes" "No"
    do
        if [ $GAMING ]; then
            break
        fi
    done

    PS3="Do you want to install dotfiles?: "
    select DOTFILES in "Yes" "No"
    do
        if [ $DOTFILES ]; then
            break
        fi
    done

    # detect wifi card
    if [ "$(lspci -d ::280)" ]; then
        WIFI=y
    fi


    PS3="Choose your desktop environment: "
    select DE in ${ENVIRONMENTS[@]}
    do
        if [ $DE ]; then
            break
        fi
    done

    # this: "<<-" ignores indentation, but only for tab characters
    cat <<- EOL > vars.sh
		export DE=$DE
		export USR=$USR
		export PASSWD=$PASSWD
		export HOSTNAME=$HOSTNAME
		export WIFI=$WIFI
		export GAMING=$GAMING
		export DOTFILES=$DOTFILES
	EOL

    print_summary
}

print_summary() {

    echo -e "\n--------------------"
    echo "Summary:"
    echo ""
    # set text to bold red
    echo "\x1b[1;33m"
    echo "The installer will erase all data on the \x1b[1;31m$ROOT_DEVICE\x1b[1;33m drive\x1b[0m"

    if [ $STRG_DEVICE ]; then
        echo "It will use \x1b[1;33m$STRG_DEVICE\x1b[0m as a storage medium and mount it on \x1b[1;33m/mnt/Storage\x1b[0m"
    fi


    if [ $WIN_DEVICE ]; then
        echo "It will use \x1b[1;33m$WIN_DEVICE\x1b[0m as a Windows partition and mount it on \x1b[1;33m/mnt/Windows\x1b[0m"
    fi

    echo "Your username will be \x1b[1;33m$USR\x1b[0m"

    echo "The machine's hostname will be \x1b[1;33m$HOSTNAME\x1b[0m"

    echo "Your Deskop Environment will be \x1b[1;33m$DE\x1b[0m"

    if [ "${GAMING}" = "Yes" ]; then
        echo "You \x1b[1;33mWILL\x1b[0m install gaming packages"
    else
        echo "You \x1b[1;33mWILL NOT\x1b[0m install gaming packages"
    fi

    if [ "${DOTFILES}" = "Yes" ]; then
        echo "You \x1b[1;33mWILL\x1b[0m install dotfiles"
    else
        echo "You \x1b[1;33mWILL NOT\x1b[0m install dotfiles"
    fi

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

update_keyring() {
    timedatectl set-ntp true # sync clock
    hwclock --systohc
    # this is useful if installing from outdated ISO
    pacman --noconfirm --ask=127 -Sy archlinux-keyring
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

    echo "UEFI=$UEFI" >> vars.sh
}

partition_and_mount_uefi() {
    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    # this: "<<-" ignores indentation, but only for tab characters
    cut -d " " -f 1 <<- EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
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

    # get partition names
    PARTITIONS=($(for PARTITION in $(dirname /sys/block/$(basename $ROOT_DEVICE)/*/partition); do
        basename $PARTITION
    done))

    # partition formatting
    mkfs.fat -F 32 /dev/$PARTITIONS[1]     # boot
    mkfs.ext4 /dev/$PARTITIONS[2] -L ROOT  # root

    # mount partitions
    mkdir -pv /mnt
    mount /dev/$PARTITIONS[2] /mnt

    mkdir -pv /mnt/boot
    mount /dev/$PARTITIONS[1] /mnt/boot

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
    # disk partitioning
    wipefs --all --force $ROOT_DEVICE
    # cut removes comments from heredoc
    # this: "<<-" ignores indentation, but only for tab characters
    cut -d " " -f 1 <<- EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
		n           # new partition
		            # primary partition
		            # partition number 1
		            # start of sector
		            # end of sector
		w           # write
	EOL

    # get partition names
    PARTITIONS=($(for PARTITION in $(dirname /sys/block/$(basename $ROOT_DEVICE)/*/partition); do
        basename $PARTITION
    done))

    # partition formatting
    mkfs.ext4 /dev/$PARTITIONS[1] -L ROOT  # root/boot

    # mount partitions
    mkdir -pv /mnt
    mount  /dev/$PARTITIONS[1] /mnt

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
    pacstrap /mnt ${BASE[*]}
    reflector > /mnt/etc/pacman.d/mirrorlist
    genfstab -U /mnt | awk '{
        if($2 == "/mnt/Windows" || $2 == "/mnt/Storage") {
            $4 = $4",nofail"
        }
        print
    }' >> /mnt/etc/fstab
}


###########
# NETWORK #
###########
setup_network() {
    # timezone
    ln -sfv /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime

    configure_locale

    echo "${HOSTNAME}" > /etc/hostname

    # this: "<<-" ignores indentation, but only for tab characters
    cat >> /etc/hosts <<- EOL
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
    # install basic system components
    if [ "$WIFI" = "y" ]; then
        BASE_APPS+=('wpa_supplicant' 'wireless_tools')
    fi

    # download database
    pacman --needed --noconfirm -Sy
    pacman --noconfirm --ask=127 --needed -S ${BASE_APPS[*]}
    # update pacman keys
    pacman-key --init
    pacman-key --populate

    install_cpu_ucode

    # install grub
    if [ "$UEFI" == y ]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    elif [ "$UEFI" == n ]; then
        grub-install --target=i386-pc $ROOT_DEVICE
    fi

    # configure grub
    echo -e '\nGRUB_DISABLE_OS_PROBER=false\n' >> /etc/default/grub
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


#########
# USERS #
#########
setup_users() {
    useradd -mG wheel,video,audio,optical,storage,games -s /bin/zsh ${USR}
    echo -e "${PASSWD}\n${PASSWD}\n" | passwd ${USR}

    export USR_HOME=$(getent passwd ${USR} | cut -d\: -f6)

    # let wheel group use sudo
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel_sudo
    # add insults to injury
    echo 'Defaults insults' > /etc/sudoers.d/insults
}


#######
# GUI #
#######
prepare_gui() {
    # add the default DM to the list of services to be enabled
    # and set up the DE variable
    case $DE in

        AWESOME)
            DE=${AWESOME[@]}
            SERVICES+=('lightdm')
            ;;
        BUDGIE)
            DE=${BUDGIE[@]}
            SERVICES+=('lightdm')
            ;;
        CINNAMON)
            DE=${CINNAMON[@]}
            SERVICES+=('lightdm')
            ;;
        DEEPIN)
            DE=${DEEPIN[@]}
            SERVICES+=('lightdm')
            ;;
        ENLIGHTENMENT)
            DE=${ENLIGHTENMENT[@]}
            SERVICES+=('lightdm')
            ;;
        GNOME)
            DE=${GNOME[@]}
            SERVICES+=('gdm')
            ;;
        KDE)
            DE=${KDE[@]}
            SERVICES+=('sddm')
            ;;
        LXQT)
            DE=${LXQT[@]}
            SERVICES+=('sddm')
            ;;
        MATE)
            DE=${MATE[@]}
            SERVICES+=('lightdm')
            ;;
        QTILE)
            DE=${QTILE[@]}
            SERVICES+=('lightdm')
            ;;
        XFCE)
            DE=${XFCE[@]}
            SERVICES+=('lightdm')
            ;;
    esac
}


#################
# CUSTOMIZATION #
#################
install_applications() {
    ins='paru --needed --useask --ask=127 --noconfirm -S'

    # let regular user run comands without password
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel_sudo

    # paru is needed for some AUR packages
    install_paru

    # install the chosen DE and GPU drivers
    sudo su ${USR} -s /bin/zsh -lc "$ins ${DE[*]}"

    detect_drivers
    if [ $GPU_DRIVERS ]; then
        sudo su ${USR} -s /bin/zsh -lc "$ins ${GPU_DRIVERS[*]}"
    fi

    # install user applications
    sudo su ${USR} -s /bin/zsh -lc "$ins ${APPS[*]}"

    if [ "${GAMING}" == "Yes" ]; then
        sudo su ${USR} -s /bin/zsh -lc "$ins ${GAMING_APPS[*]}"
    fi

    if [ "${DOTFILES}" == "Yes" ]; then
        install_dotfiles
    fi

    # remove unprotected root privileges
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel_sudo
}

install_paru() {
    OG_DIR=$(pwd)
    cd /home/${USR}

    # clone the repo
    sudo -u ${USR} git clone https://aur.archlinux.org/paru-bin.git paru
    cd paru

    # make the package
    sudo -u ${USR} makepkg -si --noconfirm

    # clean up
    cd ..
    rm -rf paru
    cd $OG_DIR
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
}

install_dotfiles() {
    # add some scripts for cronie
    mkdir -p /etc/cron.daily/
    cat <<- EOL > /etc/cron.daily/updatedb.sh
		# update mlocate database
		updatedb
	EOL

    cat <<- EOL > /etc/cron.daily/clean_cache.sh
		# clean old cache
		find /home/**/.cache -mtime +7 -exec rm -f {} \;
		find /root/.cache -mtime +7 -exec rm -f {} \;
	EOL

    chmod +x /etc/cron.daily/{updatedb.sh,clean_cache.sh}

    # this creates the default profiles for firefox
    # it's needed to have a directory to drop some configs
    sudo su ${USR} -s /bin/zsh -lc "timeout 1s firefox --headless"

    git clone https://github.com/tralph3/.dotfiles ${USR_HOME}/.dotfiles
    chmod +x ${USR_HOME}/.dotfiles/install.sh
    chown -R ${USR}:${USR} ${USR_HOME}
    sudo -u ${USR} ${USR_HOME}/.dotfiles/install.sh --noconfirm

    # neovim config installs plugins if missing automatically
    sudo -u ${USR} nvim --headless
}


############
# SERVICES #
############
enable_services() {
    for service in ${SERVICES[*]}
    do
        systemctl enable $service
    done
}

