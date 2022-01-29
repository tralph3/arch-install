# Arch Linux installation script
Installing Arch has never been simpler.

<img src="showcase.gif"></img>

## Introduction

This installation script will easily install Arch Linux on both UEFI and BIOS systems, it will automatically detect your GPU and install drivers accordingly, partition your drives, and even set up dual boot with Windows if you desire.

As this installation script was written to be quick and efficient, only these very basic settings are set when installing.

* Root drive
* Secondary drive
* Windows drive
* Username and Password
* Hostname
* Desktop Environment
* If you wish to install gaming applications

Things like timezone, partitioning scheme, filesystem, and anything else not contemplated in these settings is set up in the way I prefer, and if you are to use this script, it's heavily encouraged that you fork the repo and modify the script to fit your preferences. It will also use my personal dotfiles by default, which you probably also want to change.

## Usage

Download the script with curl:

    curl -Lo install.sh tinyurl.com/tralph3-arch

Mark the file as executable, then run it:

    chmod +x install.sh
    ./install.sh

## Modifying

Most people may be perfectly fine with the defaults, and the asked questions are enough. But almost everybody will certainly want to change what packages get installed. To do so, you'll need to modify the aptly named `packages.sh` file. In there, you will find many bash arrays that contain all packages that'll get installed. Here's a brief explanation of each one.

### BASE

This array contains the kernel and the core gnu utils. You can modify this array to install a different kernel if you so desire.

### BASE_APPS

This array contains very basic utilities, like a bootloader, network packages, and a better shell. Packages here should be used by the system rather than the user.

### APPS

This array contains user applications. You can add any package you want here **AUR packages are supported**. These programs should be used by the user.

### GAMING APPS

This array will only get installed if you select yes to the "Do you want to install gaming apps?" question on the installer. The idea is to separate tools from applications merely intended for gaming, so that you can use the same script for a personal computer or a workstation, or simply a computer that you won't be using for gaming. **AUR packages are supported**.

### SERVICES

This array won't be ran through pacman like others will. This one instead contains the name of all the systemd services that should be enabled. If you added a package that requires a service to be enabled to complete installation, you can add its name here.

### GPU_DRIVERS

This array will get populated automatically when the script detects the appropiate video drivers for your system. If you do prefer, however, you can add more packages here.

### DESKTOP ENVIRONMENTS

After all these arrays, you will see an array for each supported Desktop Environment. Firstly, there's the `ENVIRONMENTS` array, which simply contains the name of each Desktop Environment. This array is used to list the names of every supported DE at the start of the installer. The name shown here must be the same as the one of the array it represents.

Then, each of the arrays for every DE, contains the packages to be installed if that DE is selected. KDE in particular has a tons of packages listed in order to avoid the bloat that comes with the `kde-applications` meta package. All DEs will come with their own Display Manager and their respective services will get enabled.

**AUR packages are supported for all DE arrays**.

## Default Settings

So, what things do you need to change to make this script "yours"? Firstly, fork the repo and change the download urls. I used [tinyurl](https://tinyurl.com). Simply open the `install.sh` file on GitHub, click on the "Raw" button, and there's the link you have to shorten. Do the same for `definitions.sh` and `packages.sh` and replace the links inside `install.sh` with yours.

Here's a list of all the default settings, next to each section, you'll see the name of the function responsible for setting it up in the `definitions.sh` file:

### Pacman (`configure_pacman`)

* Color
* Verbose Package Lists
* Multilib repo
* Parallel Downloads (set to 10)
* ILoveCandy easter egg

### Partitioning (`partition_and_mount`)

* EXT4 filesystem
* UEFI or BIOS depending on how the live environment is booted
* UEFI:
    * GPT partition scheme
    * 512MB boot partition
    * Second partition that uses the rest of the drive
* BIOS:
    * MBR partition scheme
    * A single partition that takes the entirety fo the drive
* Windows and Storage partitions get mounted on `/mnt/Windows` or `/mnt/Storage`
* Root disk will get erased completely, no questions asked
* Windows and Storage disks only get mounted and added fstab
* Kernel 5.15's ntfs driver is used for Windows

### FSTAB (`install_base`)

* Generated automatically using UUIDs

### Timezone and Locale (`setup_network`)

* Timezone is set to `America/Argentina/Buenos_Aires`
* The `en_US.UTF-8 UTF-8` and `es_AR.UTF-8 UTF-8` locales get enabled
* Langauge is set to `en_US`

### Wifi, Bootloader and Microcode (`prepare_system`)

* `wpa_supplicant` and `wireless_tools` get installed if a wifi card is detected
* Grub is used as the bootloader
* A grub theme gets installed, os-prober gets enabled
* `amd-ucode` or `intel-ucode` get installed according to the host's CPU

### Users (`setup_users`)

* A new user gets added with the provided name and is added to the following groups:
    * wheel,video,audio,optical,storage,games
    * zsh is used as the default shell
* The user gets sudo privileges through the wheel group
* "Defaults insults" is enabled in sudoers

### Drivers and DE (`prepare_gui`)

* Here the variables to install the DE are set
* Depending on the chosen DE, a Display Manager gets installed with it

### Customization (`install_applications`)

* `paru` gets installed as the AUR helper with the `paru-bin` package to avoid compile times
* GPU drivers get detected automatically
    * Old NVIDIA cards will need to change this since the drivers are always latest
* User defined applications get installed here, along with gaming ones if appropiate
* My personal dotfiles get installed

### Services (`enable_services`)

* All services specified in its array get enabled with `systemctl`

---

So that's a quick overview of the installer. Feel free to fork and modify anything as you need, and you'll have a very quick way to install arch to your liking in no time.
