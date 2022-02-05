#!/bin/bash

# core system components
BASE=(
    'base'                          # NEEDED: Base Arch Linux system
    'linux'                         # NEEDED: Linux Kernel
    'linux-firmware'                # NEEDED: Firmware files for Linux
)

# basic system components
BASE_APPS=(
    'archlinux-keyring'             # NEEDED: Arch Linux PGP key ring
    'base-devel'                    # OPTIONAL: Various development utilities, needed for Paru and all AUR packages
    'dialog'                        # NEEDED: Dependency for many TUI programs
    'dosfstools'                    # OPTIONAL: Utilities for DOS filesystems
    'efibootmgr'                    # OPTIONAL: Modify UEFI systems from CLI
    'git'                           # OPTIONAL: Version Control System, needed for the Grub theme, Dotfiles, and Paru
    'gnu-free-fonts'                # OPTIONAL: Additional system fonts
    'grub'                          # NEEDED: Bootloader
    'linux-headers'                 # OPTIONAL: Scripts for building kernel modules
    'man-db'                        # OPTIONAL: Manual database
    'mtools'                        # OPTIONAL: Utilities for DOS disks
    'network-manager-applet'        # OPTIONAL: Applet for managing the network
    'networkmanager'                # OPTIONAL: Network connection manager
    'openssh'                       # OPTIONAL: Remotely control other systems
    'os-prober'                     # OPTIONAL: Scan for other operating systems
    'python'                        # NEEDED: Essential package for many programs
    'reflector'                     # OPTIONAL: Get download mirrors
    'usbutils'                      # OPTIONAL: Various tools for USB devices
    'wget'                          # OPTIONAL: Utility to download files
    'xdg-user-dirs'                 # OPTIONAL: Manager for user directories
    'zsh'                           # OPTIONAL: An alternate shell to bash
)

# user applications
APPS=(
    'alacritty'                     # OPTIONAL: Hardware accelerated terminal emulator
    'alsa-utils'                    # OPTIOANL: Utilities for managing alsa cards
    'android-tools'                 # OPTIONAL: Utilities for managing android devices
    'audacity'                      # OPTIONAL: Audio editor
    'cronie'                        # OPTIONAL: Task scheduler
    'cups'                          # OPTIONAL: Printer manager
    'exa'                           # OPTIONAL: Replacement for the ls command
    'ffmpeg'                        # OPTIONAL: Audio and video magic
    'firefox'                       # OPTIONAL: Web browser
    'flameshot'                     # OPTIONAL: Screenshot utility
    'gimp'                          # OPTIONAL: Image editor
    'htop'                          # OPTIONAL: System and process manager
    'mlocate'                       # OPTIONAL: Quickly find files and directories
    'mpv'                           # OPTIONAL: Suckless video player
    'neofetch'                      # OPTIONAL: Display system information, with style
    'neovim'                        # OPTIONAL: Objectively better than Emacs
    'neovim-plug'                   # OPTIONAL: Plugin manager for neovim
    'nerd-fonts-ubuntu-mono'        # OPTIONAL: Nice fonts for the terminal
    'numlockx'                      # OPTIONAL: Set numlock from CLI
    'p7zip'                         # OPTIONAL: Support for 7zip files
    'qbittorrent'                   # OPTIONAL: Torrent downloader
    'unrar'                         # OPTIONAL: Support for rar files
    'unzip'                         # OPTIONAL: Support for zip files
    'xclip'                         # OPTIONAL: Copy to clipboard from CLI
    'zenity'                        # OPTIONAL: Basic GUIs from CLI
    'zip'                           # OPTIONAL: Support for zip files
    'zsh-autosuggestions'           # OPTIONAL: Suggest commands as you type for zsh
    'zsh-syntax-highlighting'       # OPTIONAL: Syntax highlighting for zsh
    'zsh-theme-powerlevel10k'       # OPTIONAL: Stylish prompt for zsh
)

GAMING_APPS=(
    'discord'                       # OPTIONAL: Communication software
    'gamemode'                      # OPTIONAL: System optimizations for gaming
    'lib32-gamemode'                # OPTIONAL: Same, but 32bit
    'lutris'                        # OPTIONAL: Game launcher and configuration tool
    'mangohud'                      # OPTIONAL: HUD for monitoring system and logging
    'proton-ge-custom-bin'          # OPTIONAL: Extra fixes and patches for Proton
    'steam'                         # OPTIONAL: Game storefront
    'steam-fonts'                   # OPTIONAL: Fonts for that weird game storefront
    'steam-metadata-editor-git'     # OPTIONAL: Edit metadata for your Steam games
    'steam-native-runtime'          # OPTIONAL: A native runtime for the weird storefront
    'wine'                          # OPTIONAL: Run Windows applications on Linux
    'wine-gecko'                    # OPTIONAL: Wine's replacement for Internet Explorer
    'wine-mono'                     # OPTIONAL: Wine's replacement for .Net Framework
    'winetricks'                    # OPTIONAL: Script to install libraries in Wine
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
    'QTILE'
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

QTILE=(
    'dunst'
    'engrampa'
    'feh'
    'lightdm'
    'lightdm-gtk-greeter'
    'mint-backgrounds-una'
    'pcmanfm'
    'picom-git'
    'qtile'
    'rofi'
    'xorg-server'
)

XFCE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'xfce4'
    'xfce4-goodies'
    'xorg-server'
)
