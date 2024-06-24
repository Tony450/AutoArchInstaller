#!/bin/bash

##############################################################################
# Copyright (C) 2024 Antonio Manuel Hernández De León
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
##############################################################################

#Usage:
#       ./troubleshooting-install.sh |& tee troubleshooting-install.log

#NOTE:
#   This script must be run after a restart, otherwise it won't work

username=$(whoami)
temporary_vmware_solution=true
no_confirmation="--noconfirm"

#Mark Informant news as read
echo -e "\n------------------------------Mark Informant news as read------------------------------"

sudo informant read --all

#Zsh-theme-powerlevel10k-git installation retry if "Early EOF. Invalid index-pack output" issue happens
echo -e "\n------------------------------Zsh-theme-powerlevel10k-git installation retry if "Early EOF. Invalid index-pack output" issue happens------------------------------"

powerlevel10k_installation=$(pacman -Q | grep zsh-theme-powerlevel10k)
if [[ ! ${powerlevel10k_installation} ]]; then
    paru -S zsh-theme-powerlevel10k-git $no_confirmation
fi

#VMware
echo -e "\n------------------------------VMware------------------------------"

cd /home/$username/Downloads
git clone https://github.com/mkubecek/vmware-host-modules.git
cd vmware-host-modules
vmversion=$( pacman -Q | grep vmware-workstation | cut -f 2 -d ' ' | cut -f 1 -d '-' );
if [[ $temporary_vmware_solution = true ]]; then
    if [[ ${vmversion//.} -gt "1751" ]]; then
        vmversion="17.5.1"
    fi
fi
beginning="origin/workstation-"; git checkout -b $vmversion "${beginning}${vmversion}"
sudo make
cd ..
sudo rm -r vmware-host-modules
cd