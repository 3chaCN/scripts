#!/bin/bash

# usage : <destination>

paths=(/proc /sys /home /var/cache/xbps /tmp /var/lib/libvirt/images)
today=$(date +%Y-%m-%d)
arch_name="rootfs-backup-"$today.tar.bz2
dest=$1

xbps-query -l > /installed-pkgs.txt

for p in ${paths[@]}
do
	find $p 2&>1 >> $dest/.exclude-rootfs.txt
done

echo $dest/$arch_name >> $dest/.exclude-rootfs.txt

tar -X $dest/.exclude-rootfs.txt -cvjpf $dest/$arch_name /

rm $dest/.exclude-rootfs.txt
