#!/bin/bash

stat=$(cat /sys/class/power_supply/BAT0/uevent | grep STATUS | cut -d '=' -f 2)

if [[ "$stat" == "Discharging" ]]; then
	powerprofilesctl set power-saver;
else
	powerprofilesctl set balanced;
fi
