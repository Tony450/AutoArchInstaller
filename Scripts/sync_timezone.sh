#!/bin/bash

ip link show | grep -qE "tun|tap|wg" && exit 0                                                      #Do not trust VPNs

hotstpot=$(nmcli -g GENERAL.METERED dev show $(ip route list 0/0 | awk '{print $5}'))               #Do not trust hotstpot/tethering

if [[ "$hotstpot" == *"yes"* ]]; then
    exit 0
fi

local_timezone=$(timedatectl show -p Timezone --value)
timezone=$(curl -s https://ipapi.co/timezone)

# Update if they are not they same
if [ -n "$timezone" ] && [ "$timezone" != "$local_timezone" ]; then
    sudo timedatectl set-timezone "$timezone"
fi