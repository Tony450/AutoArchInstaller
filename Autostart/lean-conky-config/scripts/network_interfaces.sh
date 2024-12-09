#!/bin/bash

for line in $(ifconfig | grep -n -E "eth|enp0|wlan" | grep -v "ether" | grep -Eo '^[^:]+'); do

    ifconfig | head -n $(($line+1)) | tail -1 | grep "inet " | awk '{print $2}'

done
