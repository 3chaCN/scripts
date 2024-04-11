#!/bin/bash

part=/dev/disk/by-label/LEK

# cryptsetup luksOpen --test-passphrase /dev/sda3 sda3_crypt

until [ -b $part ];
do
	echo -n "Insert usb key and press enter: "
	read
done

mount $part /mnt

