#!/bin/bash

# need : iw

# ssid, signal, security (WEP; WPA (TKIP/CCMP); wps

# remove duplicates
# change order
# format : ssid, signal, auth, wps

#iw dev wlp0s20u2 scan | sed -En 's/(\t+|^\s+\*)//g ; /signal:/p ; /SSID:\s(.*)\1/p ; /Authentication suites:/p ; /WPS:/p'

#iw dev wlp3s0 scan | sed -En 's/(\t+|^\s+\*)//g ; s/\s+//g ;  /signal:/p ; /SSID:(.*)\1/p  ; /Groupcipher:/p ; /WPS:/p' |sed 'N ; s/\(signal:.*\)\n\(SSID:.*\)/\2;\1/ ; s/^\s\(.*\)/\1/g' > /tmp/.wifi_targets.txt

for w in $(cat /tmp/.wifi_targets.txt)
do
	#echo $w
	ssid=$(echo ${w} |xargs | cut -d ';' -f 1)
	#signal=$(echo ${wlan} | cut -d ';' -f 2 | cut -d ':' -f 2 | xargs)
	printf "${ssid} ${signal}"
done
