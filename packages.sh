#!/bin/bash

# core system components
BASE=(
    'base'
    'linux'
    'linux-firmware'
)

# basic system components
BASE_APPS=(
    'base-devel'
    'dialog'
    'dosfstools'
    'efibootmgr'
    'git'
    'gnu-free-fonts'
    'grub'
    'linux-headers'
    'man-db'
    'mtools'
    'network-manager-applet'
    'networkmanager'
    'openssh'
    'os-prober'
    'python'
    'reflector'
    'usbutils'
    'wget'
    'xdg-user-dirs'
    'zsh'
)

# user applications
APPS=(
    'alacritty'
    'android-tools'
    'audacity'
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
ENVIRONMENTS=(
    'BUDGIE'
    'CINNAMON'
    'DEEPIN'
    'ENLIGHTENMENT'
    'GNOME'
    'KDE'
    'LXQT'
    'MATE'
    'XFCE'
)

BUDGIE=(
    'budgie-desktop'
    'lightdm'
    'lightdm-gtk-greeter'
    'xorg-server'
)

CINNAMON=(
    'cinnamon'
    'lightdm'
    'lightdm-gtk-greeter'
    'xorg-server'
)

DEEPIN=(
    'deepin'
    'deepin-extra'
    'lightdm'
    'lightdm-gtk-greeter'
    'xorg-server'
)

ENLIGHTENMENT=(
    'enlightenment'
    'lightdm'
    'lightdm-gtk-greeter'
    'terminology'
    'xorg-server'
)

GNOME=(
    'gdm'
    'gnome'
    'gnome-tweaks'
)

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
    'kontrast'
    'kwrite'
    'okular'
    'plasma'
    'print-manager'
    'sddm'
    'xdg-desktop-portal-kde'
)

LXQT=(
    'breeze-icons'
    'lxqt'
    'lxqt-connman-applet'
    'sddm'
    'slock'
)

MATE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'mate'
    'mate-extra'
    'xorg-server'
)

XFCE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'xfce4'
    'xfce4-goodies'
    'xorg-server'
)
