#!/bin/bash
# this script will check that all the packages in the package.sh file are valid
# all the returned packages should be invalid, meaning there's a typo
# note that this doesn't detect package groups, so groups like "base-devel"
# are false positives
source packages.sh

PACKAGES+=${BASE[@]}\ ${BASE_APPS[@]}\ ${APPS[@]}\ ${GAMING_APPS[@]}\ ${BUDGIE[@]}\ ${CINNAMON[@]}\ ${DEEPIN[@]}\ ${ENLIGHTENMENT[@]}\ ${GNOME[@]}\ ${KDE[@]}\ ${LXQT[@]}\ ${MATE[@]}\ ${QTILE[@]}\ ${XFCE[@]}
echo ${PACKAGES[@]} | tr " " "\n" > temp
comm -23 <(sort -u temp) <(sort <(wget -q -O - https://aur.archlinux.org/packages.gz | gunzip) <(pacman -Ssq))
rm temp
