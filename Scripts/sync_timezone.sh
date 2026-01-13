#!/bin/bash

ip link show | grep -qE "tun|tap|wg" && exit 0                                                      #Do not trust VPNs

hotstpot=$(nmcli -g GENERAL.METERED dev show $(ip route list 0/0 | awk '{print $5}'))               #Do not trust hotstpot/tethering

if [[ "$hotstpot" == *"yes"* ]]; then
    exit 0
fi

local_time_zone=$(timedatectl show -p Timezone --value)
time_zone=$(curl -s https://ipapi.co/timezone)

# Update if they are not they same
if [ -n "$time_zone" ] && [ "$time_zone" != "$local_time_zone" ]; then
    sudo timedatectl set-timezone "$time_zone"
fi