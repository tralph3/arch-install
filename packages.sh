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
    'wireplumber'                   # OPTIONAL: Session manager for Pipewire
    'cronie'                        # OPTIONAL: Task scheduler
    'cups'                          # OPTIONAL: Printer manager
    'exa'                           # OPTIONAL: Replacement for the ls command
    'ffmpeg'                        # OPTIONAL: Audio and video magic
    'firefox'                       # OPTIONAL: Web browser
    'flameshot'                     # OPTIONAL: Screenshot utility
    'gimp'                          # OPTIONAL: Image editor
    'helvum'                        # OPTIONAL: GUI for Pipewire configuration
    'htop'                          # OPTIONAL: System and process manager
    'mlocate'                       # OPTIONAL: Quickly find files and directories
    'mpv'                           # OPTIONAL: Suckless video player
    'mtpfs'                         # OPTIONAL: File transfer for android devices
    'neofetch'                      # OPTIONAL: Display system information, with style
    'neovim'                        # OPTIONAL: Objectively better than Emacs
    'pavucontrol'                   # OPTIONAL: Pulse Audio volume control
    'neovim-plug'                   # OPTIONAL: Plugin manager for neovim
    'nerd-fonts-ubuntu-mono'        # OPTIONAL: Ubuntu fonts patched with icons
    'numlockx'                      # OPTIONAL: Set numlock from CLI
    'p7zip'                         # OPTIONAL: Support for 7zip files
    'pipewire'                      # OPTIONAL: Modern audio router and processor
    'pipewire-alsa'                 # OPTIONAL: Pipewire alsa configuration
    'pipewire-pulse'                # OPTIONAL: Pipewire replacement for pulseaudio
    'qbittorrent'                   # OPTIONAL: Torrent downloader
    'ttf-ubuntu-font-family'        # OPTIONAL: Ubuntu fonts
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
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

CINNAMON=(
    'cinnamon'
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

DEEPIN=(
    'deepin'
    'deepin-extra'
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

ENLIGHTENMENT=(
    'enlightenment'
    'lightdm'
    'lightdm-gtk-greeter'
    'terminology'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

GNOME=(
    'gdm'
    'gnome'
    'gnome-tweaks'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gnome'
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
    'xdg-desktop-portal'
    'xdg-desktop-portal-kde'
)

LXQT=(
    'breeze-icons'
    'lxqt'
    'lxqt-connman-applet'
    'sddm'
    'slock'
    'xdg-desktop-portal'
    'xdg-desktop-portal-kde'
)

MATE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'mate'
    'mate-extra'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

QTILE=(
    'breeze-gtk'
    'dex'
    'dunst'
    'engrampa'
    'feh'
    'lightdm'
    'lightdm-gtk-greeter'
    'mint-backgrounds-una'
    'papirus-icon-theme'
    'picom-git'
    'qtile'
    'rofi'
    'thunar'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xorg-server'
)

XFCE=(
    'lightdm'
    'lightdm-gtk-greeter'
    'xdg-desktop-portal'
    'xdg-desktop-portal-gtk'
    'xfce4'
    'xfce4-goodies'
    'xorg-server'
)
