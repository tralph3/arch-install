# Arch Linux installation script

## Introduction

This installation script will easily install Arch Linux on both UEFI and BIOS systems, it will automatically detect your GPU and install drivers accordingly, partition your drives, and even set up dual boot with Windows if you desire.

As this installation script was written to be quick and efficient, only very basic questions are asked when installing. Among them:

* Root drive
* Secondary drive
* Windows drive
* Username and Password
* Hostname
* Desktop Environment
* If you wish to install gaming applications

Things like timezone, partitioning scheme, filesystem, and anything else not contemplated in these questions is set up in the way I prefer, and if you are to use this script, it's heavily encouraged that you fork the repo and modify the script to fit your preferences. It will also use my personal dotfiles by default, which you probably also want to change.

## Usage

Boot up the Arch Linux installer, and install git with:

    pacman -Sy git

Then clone the repository with:

    git clone https://github.com/tralph3/arch-install

Then `cd` into its folder, and run the installer:

    cd arch-install
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

#### DESKTOP ENVIRONMENTS

After all these arrays, you will see an array for each supported Desktop Environment. Firstly, there's the `ENVIRONMENTS` array, which simply contains the name of each Desktop Environment. This array is used to list the names of every supported DE at the start of the installer. The name shown here must be the same as the one of the array it represents.

Then, each of the arrays for every DE, contains the packages to be installed if that DE is selected. KDE in particular has a tons of packages listed in order to avoid the bloat that comes with the `kde-applications` meta package. All DEs will come with their own Display Manager and their respective services will get enabled.
