#!/bin/bash

# core system components
BASE=(
    'base'
    'linux'
    'linux-firmware'
)

# basic system components
BASE_APPS=(
    'dialog'
    'dosfstools'
    'efibootmgr'
    'git'
    'gnu-free-fonts'
    'grub'
    'linux-headers'
    'man-db'
    'network-manager-applet'
    'networkmanager'
    'openssh'
    'os-prober'
    'python'
    'reflector'
    'sudo'
    'usbutils'
    'wget'
    'xdg-user-dirs'
)

# user applications
APPS=(
    'android-tools'
    'audacity'
    'base-devel'
    'cronie'
    'cups'
    'exa'
    'ffmpeg'
    'firefox'
    'flameshot'
    'gimp'
    'htop'
    'mlocate'
    'mpv'
    'mtools'
    'neofetch'
    'neovim'
    'neovim-plug'
    'nerd-fonts-ubuntu-mono'
    'numlockx'
    'p7zip'
    'qbittorrent'
    'unrar'
    'unzip'
    'xclip'
    'zenity'
    'zip'
    'zsh'
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
    'zsh-theme-powerlevel10k'
)

GAMING_APPS=(
    'discord'
    'gamemode'
    'lib32-gamemode'
    'lutris'
    'mangohud'
    'proton-ge-custom-bin'
    'steam'
    'steam-fonts'
    'steam-metadata-editor-git'
    'steam-native-runtime'
    'wine'
    'wine-gecko'
    'wine-mono'
    'winetricks'
)

# all of these will get enabled
SERVICES=(
    'cronie'
    'cups'
    'NetworkManager'
    'sshd'
)

# this will get populated automatically
GPU_DRIVERS=()


########################
# DESKTOP ENVIRONMENTS #
########################
KDE=(
    'ark'
    'dolphin'
    'dolphin-plugins'
    'ffmpegthumbs'
    'filelight'
    'gwenview'
    'kcalc'
    'kcharselect'
    'kcolorchooser'
    'kcron'
    'kdeconnect'
    'kdegraphics-thumbnailers'
    'kdenetwork-filesharing'
    'kdesdk-thumbnailers'
    'kdialog'
    'kipi-plugins'
    'kmix'
    'kolourpaint'
    'konsole'
    'kontrast'
    'kwrite'
    'okular'
    'plasma'
    'print-manager'
    'sddm'
    'xdg-desktop-portal-kde'
)

GNOME=(
    'gdm'
    'gnome'
    'gnome-tweaks'
)

DEEPIN=(
    'deepin'
    'deepin-extra'
    'lightdm'
    'lightdm-gtk-greeter'
    'xorg-server'
)

XFCE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'xfce4'
    'xfce4-goodies'
    'xorg-server'
)

ENLIGHTENMENT=(
    'enlightenment'
    'lightdm'
    'lightdm-gtk-greeter'
    'terminology'
    'xorg-server'
)

MATE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'mate'
    'mate-extra'
    'xorg-server'
)
