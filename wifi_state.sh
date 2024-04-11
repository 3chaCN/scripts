#!/bin/bash

wlan_dev="wlp3s0"

state=$(nmcli general status | tail -n 1 | awk '{print $1'})
wlan_ssid=$(nmcli -t c | grep ${wlan_dev} | cut -d ':' -f 1)
inet=$(ip -o ad |grep -iE "${wlan_dev}.*inet " | awk '{print $4}')

printf "${wlan_ssid}[${state}] (${inet})"
