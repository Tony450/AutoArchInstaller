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
#       ./software-install.sh |& tee software-install.log
#       ./software-install.sh > >(tee software-install-stdout.log) 2> >(tee software-install-stderr.log >&2)

username=$(whoami)
no_confirmation="--noconfirm"
working_directory=$(pwd)
git_user_name=""
git_user_email=""

if [[ $git_user_name == ""  || $git_user_email == "" ]]; then
    echo "Initialize the required data first"
    exit
fi

sudo pacman -Syy

#Password timeout
echo -e "\n------------------------------Password timeout------------------------------"

sudo echo -e "Defaults  timestamp_timeout=300" | sudo tee -a /etc/sudoers > /dev/null

#AUR helper
echo -e "------------------------------AUR helper------------------------------"

cd /home/$username/Downloads
git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si $no_confirmation                         #Install paru helper
cd

#BlackArch Linux
echo -e "\n------------------------------BlackArch Linux------------------------------"

cd /home/$username/Downloads
curl -O https://blackarch.org/strap.sh && chmod +x strap.sh && sudo ./strap.sh                                          #Install BlackArch
sudo rm -r paru-bin && rm strap.sh
cd

#Multilib repository
echo -e "\n------------------------------Multilib repository------------------------------"

mline=$(grep -n "\\[multilib\\]" /etc/pacman.conf | cut -d: -f1)                                                        #Enable Multilib repository
rline=$(($mline + 1))
sudo sed -i ''$mline's|#\[multilib\]|\[multilib\]|g' /etc/pacman.conf
sudo sed -i ''$rline's|#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|g' /etc/pacman.conf

sudo pacman -Syy

#Upgrade
echo -e "\n------------------------------Upgrade------------------------------"

sudo pacman -Syu $no_confirmation                                                                                       #Upgrade the system


#First group of programs
echo -e "\n------------------------------First group of programs------------------------------"

sudo pacman -S neofetch firefox man-db man-pages wget bandwhich git-delta tmux byobu tcpdump wireshark-qt python-pipx gimp hashcat john kcalc ark kclock kmousetool kmag ktimetracker okteta kbackup kdenlive spectacle kdeconnect audacity plasma-systemmonitor filelight partitionmanager kfind ksystemlog kcolorchooser khelpcenter kompare sweeper kamoso kleopatra kcachegrind elisa kalzium kmix kgeography ksudoku knavalbattle kget skanpage kmines ktouch kigo marble kontact kapman kdiamond kweather cantor kalgebra umbrello cervisia klines kmplot step kfourinline krecorder itinerary zanshin telly-skout krename kid3 kstars kmymoney arianna kommit metasploit nmap arp-scan torbrowser-launcher traceroute kompare isoimagewriter elisa kclock marknote kmymoney skrooge crunch cewl bettercap mentalist cvemap iaxflood beef set wordlistctl trash-cli aircrack-ng ripgrep-all ncdu obs-studio autorandr imagemagick ktorrent zip unzip ecryptfs-utils conky conky-manager xdotool timeshift keepass locate mdcat xclip neovim lsd bat bind nodejs npm xdotool kmail korganizer kaddressbook akregator knotes plasma-wayland-protocols callaudiod gwenview libreoffice-still poppler cronie gnome-2048 flatpak virt-what feh fzf hexedit lf pv jq nerd-fonts reflector iwd openvpn mosh libpam-google-authenticator dialog pv $no_confirmation

#phonon-qt5-vlc
#tesseract 5.3.4-2
#tesseract-data-afr 2:4.1.0-4
#tesseract-data-osd 2:4.1.0-4

#Foxit Reader download with megatools
echo -e "\n------------------------------Foxit Reader download with megatools------------------------------"

sudo pacman -S megatools $no_confirmation
cd /home/$username/Downloads
megadl "https://mega.nz/file/NwAkVJYD#4BdcIhZhxU9jYrDWw7MRTPpwqXG3hF2-oOwrUyfre_0"
sudo pacman -Rs megatools $no_confirmation
cd

#Second group of programs
echo -e "\n------------------------------Second group of programs------------------------------"

paru -S visual-studio-code-bin google-chrome teamviewer cyberchef-web hibernator-git 4kvideodownloader megasync-bin keurocalc subtitlecomposer-git codevis pamac-aur plasma-dialer-git vmware-workstation markdown2pdf-git zsh-syntax-highlighting zsh-autosuggestions scrub ntfysh-bin snapd insync python-nvidia-ml-py zsh-theme-powerlevel10k-git hollywood wkhtmltopdf-static icu74 bashdb $no_confirmation #activitywatch-bin?  python-pynvml

sudo updatedb                                                                                                           #For locate command to work

#Terminal: ZSH, Wezterm and Powerlevel10K
echo -e "\n------------------------------Terminal: ZSH, Wezterm and Powerlevel10K------------------------------"

cd $working_directory
sudo usermod --shell /usr/bin/zsh $username
sudo localectl set-x11-keymap es

cp -f Terminal/zshrc /home/$username/.zshrc
cp -f Terminal/wezterm.lua /home/$username/.wezterm.lua
cp -f Terminal/p10k.zsh /home/$username/.p10k.zsh

cd /usr/share/zsh/plugins
sudo mkdir zsh-sudo && sudo mkdir zsh-interactive-cd

cd /home/$username/Downloads
wget https://raw.githubusercontent.com/mrjohannchang/zsh-interactive-cd/master/zsh-interactive-cd.plugin.zsh
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

sudo cp sudo.plugin.zsh /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
sudo cp zsh-interactive-cd.plugin.zsh /usr/share/zsh/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
rm sudo.plugin.zsh zsh-interactive-cd.plugin.zsh
cd

sudo usermod --shell /usr/bin/zsh root
sudo ln -s -f /home/$username/.zshrc /root/.zshrc                                                                       #To make the root zsh config be the same as tony450

sudo cp -f /home/$username/.p10k.zsh /root


#Hibernation
echo -e "\n------------------------------Hibernation------------------------------"

# sudo hibernator
sudo sed -i -e 's/modconf kms keyboard/modconf resume kms keyboard/g' /etc/mkinitcpio.conf
uuid=$( cat /etc/fstab | grep swap | cut -f 1); beginning="s/quiet/quiet splash resume=";end="/g"; sudo sed -i -e "${beginning}${uuid}${end}" /etc/default/grub
sudo mkinitcpio -p linux
sudo grub-mkconfig -o /boot/grub/grub.cfg


#Digital certificates
echo -e "\n------------------------------Digital certificates------------------------------"

sudo pacman -S pcsclite pcsc-tools opensc nss icedtea-web $no_confirmation
paru -S libpkcs11-dnie configuradorfnmt autofirma ca-certificates-dnie $no_confirmation

/opt/google/chrome/chrome &
sleep 3
kill -9 $!

cd /home/$username/.pki/nssdb
sudo chown $username:$username pkcs11.txt
modutil -dbdir sql:/home/$username/.pki/nssdb -add "DNI-e" -libfile /usr/lib/opensc-pkcs11.so
cd

sudo updatedb                                                                                                           #For locate command to work
# locate opensc | grep "/opensc-pkcs11.so" | xargs ls -lth                                                              #Run this command to be able to add the security device on Mozilla Firefox

#Autostart scripts
echo -e "\n------------------------------Autostart scripts------------------------------"

cd $working_directory
cp -r Autostart /home/$username
mv /home/$username/Autostart/lean-conky-config/local2.conf /home/$username/Autostart/lean-conky-config/local.conf
cd

#Wallpapers and icons
echo -e "\n------------------------------Wallpapers and icons------------------------------"

cd $working_directory && cd Icons
cp -r Application\ Launcher /home/$username/Pictures
cd ..
sudo cp -r -f Wallpapers/Login\ Screen/Breeze/* /usr/share/sddm/themes/breeze
mkdir -p /home/$username/Pictures/Wallpapers/Wallpaper\ 0/
sudo cp -r -f Wallpapers/Desktop/Wallpaper\ 0/* /home/$username/Pictures/Wallpapers/Wallpaper\ 0/
cd

#Foxit Reader
echo -e "\n------------------------------Foxit Reader------------------------------"

cd /home/$username/Downloads
sudo chmod +x FoxitReader.enu.setup.2.4.5.0727\(rb70e8df\).x64.run
sudo ./FoxitReader.enu.setup.2.4.5.0727\(rb70e8df\).x64.run
rm FoxitReader.enu.setup.2.4.5.0727\(rb70e8df\).x64.run
cd

#Cyberchef
echo -e "\n------------------------------Cyberchef------------------------------"

cd $working_directory
sudo chmod +x Scripts/cyberchef.sh
sudo mkdir /opt/cyberchef && sudo cp Scripts/cyberchef.sh /opt/cyberchef/cyberchef
cd


#Enable services
echo -e "\n------------------------------Enable services------------------------------"

sudo systemctl enable wpa_supplicant.service && sudo systemctl start wpa_supplicant.service
sudo systemctl enable teamviewerd.service && sudo systemctl start teamviewerd.service
sudo systemctl enable cronie && sudo systemctl start cronie
sudo systemctl enable pcscd.service && sudo systemctl start pcscd.service
sudo systemctl enable vmware-networks.service && sudo systemctl start vmware-networks.service
sudo systemctl enable vmware-usbarbitrator.service && sudo systemctl start vmware-usbarbitrator.service
sudo systemctl enable iwd.service && sudo systemctl start iwd.service

#Flathub: ZapZap, Telegram and Paper Clip
echo -e "\n------------------------------Flathub: ZapZap, Telegram and Paper Clip------------------------------"

flatpak install flathub com.rtosta.zapzap --assumeyes
flatpak install flathub org.telegram.desktop --assumeyes
flatpak install flathub io.github.diegoivan.pdf_metadata_editor --assumeyes


#Modern CSV
echo -e "\n------------------------------Modern CSV------------------------------"

cd /home/$username/Downloads
curl -O https://www.moderncsv.com/release/ModernCSV-Linux-v2.0.8.tar.gz
tar -xvzf ModernCSV-Linux-v2.0.8.tar.gz
cd moderncsv2.0.8 && chmod +x install.sh && sudo ./install.sh
cd .. && sudo rm -r moderncsv2.0.8
sudo rm ModernCSV-Linux-v2.0.8.tar.gz
cd


#Wireshark configuration
echo -e "\n------------------------------Wireshark configuration------------------------------"

sudo gpasswd -a $username wireshark



#Git configuration
echo -e "\n------------------------------Git configuration------------------------------"

git config --global core.editor "vim"
git config --global user.name $git_user_name
git config --global user.email $git_user_email


#Wine
echo -e "\n------------------------------Wine------------------------------"

sudo pacman -S wine wine-mono wine-gecko winetricks $no_confirmation
wine --version
sudo pacman -S --asdeps --needed $(pacman -Si wine | sed -n '/^Opt/,/^Conf/p' | sed '$d' | sed 's/^Opt.*://g' | sed 's/^\s*//g' | tr '\n' ' ') $no_confirmation
sudo pacman -S --needed samba gnutls lib32-gnutls $no_confirmation
# wine wincfg


#Systemback
echo -e "\n------------------------------Systemback------------------------------"

sudo echo -e "[yuunix_aur]\nSigLevel = Optional TrustedOnly\nServer = https://shadichy.github.io/\$repo/\$arch" | sudo tee -a /etc/pacman.conf > /dev/null
sudo pacman -Syy
sudo pacman -S systemback $no_confirmation
headn=$( head -n -3 /etc/pacman.conf ); sudo echo "$headn" | sudo tee /etc/pacman.conf > /dev/null
sudo pacman -Syy


#Charging threshold for laptops
echo -e "\n------------------------------Charging threshold for laptops------------------------------"

chassis_type=$(sudo dmidecode --string chassis-type);
if [[ $chassis_type == "Laptop" || $chassis_type == "Notebook" || $chassis_type == "Sub Notebook" ]]; then
    sudo echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold > /dev/null
    sudo echo -e "# Battery Charge Threshold\n@reboot root echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold" | sudo tee -a /etc/crontab
fi


#Virtual Machine
echo -e "\n------------------------------Virtual Machine------------------------------"

if [[ $(sudo virt-what) ]]; then
    sudo pacman -S gtkmm open-vm-tools xf86-video-vmware xf86-input-vmmouse $no_confirmation
    sudo systemctl enable vmtoolsd && sudo systemctl start vmtoolsd
    sudo systemctl enable vmware-vmblock-fuse && sudo systemctl start vmware-vmblock-fuse
    sudo mkdir /mnt/hgfs & sudo echo -e "\n# Shared folders\n vmhgfs-fuse /mnt/hgfs fuse defaults,allow_other 0 0" >> /etc/fstab & sudo mount -a
fi


#Latex
echo -e "\n------------------------------Latex------------------------------"

paru -S miktex $no_confirmation
sudo pacman -S libxcrypt-compat $no_confirmation
sudo /opt/miktex/bin/miktex-console --admin --finish-setup                                                              #The window must be closed


#Zsh-theme-powerlevel10k-git installation retry if "Early EOF. Invalid index-pack output" issue happens
echo -e "\n------------------------------Zsh-theme-powerlevel10k-git installation retry if "Early EOF. Invalid index-pack output" issue happens------------------------------"

powerlevel10k_installation=$(pacman -Q | grep zsh-theme-powerlevel10k)
if [[ ! ${powerlevel10k_installation} ]]; then
    paru -S zsh-theme-powerlevel10k-git $no_confirmation
fi

#Informant
echo -e "\n------------------------------Informant------------------------------"

paru -S informant $no_confirmation

#Nvchad
echo -e "\n------------------------------Nvchad------------------------------"

cd /home/$username/Downloads
git clone https://github.com/NvChad/starter /home/$username/.config/nvim && nvim                                        #Type :q! and hit Enter (it seems that it doesn't work, but it does)
sudo git clone https://github.com/NvChad/starter /root/.config/nvim && sudo nvim                                        #Type :q! and hit Enter (it seems that it doesn't work, but it does)
cd

sudo updatedb                                                                                                           #For locate command to work

#Mp3DownTagger
echo -e "\n------------------------------Mp3DownTagger------------------------------"
cd /home/$username/Downloads
git clone https://github.com/Tony450/Mp3DownTagger
cd Mp3DownTagger/Installer/GNU\ Linux
chmod +x install.sh
./install.sh
cd .. && sudo rm -r Mp3DownTagger
cd

#Password timeout
echo -e "\n------------------------------Password timeout------------------------------"

headn=$( sudo head -n -1 /etc/sudoers ); sudo echo "$headn" | sudo tee /etc/sudoers > /dev/null



