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

#Usage: ./base-install.sh |& tee base-install.log

username=""
hostname=""
efi_partition_name=""
no_confirmation="--noconfirm"

if [[ $username == "" || $hostname == ""  || $efi_partition_name == "" ]]; then
    echo "Initialize the required data first"
    exit
fi


#Clock and time zone
echo -e "------------------------------Clock, time zone and languages------------------------------"

ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime                                                 #Configure the time zone

hwclock --systohc                                                                                       #Set the Hardware clock from the System Clock

timedatectl set-local-rtc 1 --adjust-system-clock                                                       #To avoid time issues when changing to Windows

sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen                                    #Enable sudo privilege to the wheel group

locale-gen                                                                                              #Generate the locales

echo "LANG=en_US.UTF-8" > /etc/locale.conf                                                              #Specify which language will be used by default

echo "KEYMAP=es" > /etc/vconsole.conf                                                                   #Specify the keyboard layout

#Hostname
echo -e "\n------------------------------Hostname------------------------------"

echo $hostname > /etc/hostname                                                                          #Specify the hostname

echo -e "127.0.0.1   localhost\n::1     localhost\n127.0.1.1   $hostname" >> /etc/hosts                 #Configure local host name resolution to some programs

#Network
echo -e "\n------------------------------Network------------------------------"

systemctl enable NetworkManager                                                                         #Enable NetworkManager service

#Users
echo -e "\n------------------------------Users------------------------------"

echo "Type the root password"

passwd                                                                                                  #Set the root password

useradd -m -G wheel $username                                                                           #Create a non-root user

echo "Type the $username password"

passwd $username                                                                                        #Set the password of the non-root user

sed -i -e "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers                        #Enable sudo privilege to the wheel group

#Base software 1
echo -e "\n------------------------------Base software 1------------------------------"

pacman -Syy

pacman -S intel-ucode $no_confirmation                                                                  #Install Intel microcode

pacman -S grub efibootmgr os-prober $no_confirmation                                                    #Install grub bootloader

#Bootloader
echo -e "\n------------------------------Bootloader------------------------------"

mkdir /boot/efi && mount /dev/$efi_partition_name /boot/efi                                             #Create an EFI directory and mount the EFI partition

grub-install --target=x86_64-efi --bootloader-id=arch_linux                                             #Install grub in the newly mounted EFI partition

sed -i -e 's/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/g' /etc/default/grub                        #Enable OS prober
sed -i -e 's/#GRUB_DISABLE_SUBMENU/GRUB_DISABLE_SUBMENU/g' /etc/default/grub                            #Disable grub submenu
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub                                         #Set GRUB_TIMEOUT=0

grub-mkconfig -o /boot/grub/grub.cfg                                                                    #Generate grub configuration file

#Base software 2
echo -e "\n------------------------------Base software 2------------------------------"

pacman -S xorg-server $no_confirmation                                                                  #Install Xorg

pacman -S xf86-video-intel nvidia nvidia-utils $no_confirmation                                         #Install  Intel and Nvidia graphics drivers

pacman -S plasma plasma-workspace $no_confirmation                                                      #Install plasma desktop environment

#Display manager
echo -e "\n------------------------------Display manager------------------------------"

systemctl enable sddm                                                                                   #Enable the plasma display manager

#Upgrade
echo -e "\n------------------------------Upgrade------------------------------"

pacman -Syu $no_confirmation

