#!/bin/bash

DSK="$1"
MNT="$2"

if [ -n $DSK ]; then
	DSK="/media/rscudeller/SAMSUNG/ArquivosPessoais/pa/pa.vdi"
fi

if [ -n $MNT ]; then 
	MNT="/mnt/pa"
fi

sudo modprobe nbd
sudo qemu-nbd -c /dev/nbd0 $DSK
#/media/rscudeller/SAMSUNG/ArquivosPessoais/pa/pa.vdi
sudo mount -o noatime,noexec /dev/nbd0p1 $MNT
