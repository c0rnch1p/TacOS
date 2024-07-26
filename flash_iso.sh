#!/bin/bash

DEFDIR='iso_out'
ISOFILE=$(find "$ISODIR" -maxdepth 1 -type f -name *'.iso' -print -quit)

comp_func(){
	local COMPREPLY
	COMPREPLY=$(compgen -W "$2" -- "${COMP_WORDS[COMP_CWORD]}")
} complete -F comp_func read

select_drive(){
	while true; do
		if [ -z "$DEVICE" ]; then echo -e '\nAvailable drives'
			lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep 'disk' | sed 's/^/- \/dev\//'
		fi
		echo -e '\nEnter drive name\n'
		read -rep '- ' DEVICE
		if [ -e "$DEVICE" ]; then break
		else echo -e '\nInvalid device name'
		fi
	done
}

write_iso(){
	sudo umount "$DEVICE"* &>'/dev/null'
	echo -e '\nOverwrite all existing data on the drive (y/n)\n'
	read -p '- ' ANS
	if [ "$ANS" == 'y' ]; then echo
		if sudo dd if="$ISOFILE" | pv -s $(stat -c%s "$ISOFILE") -w 80 -N 'Flashing iso' | sudo dd of="$DEVICE"; then
			echo -e "\n$ISOFILE flashed to $DEVICE, ejecting now"
			if sudo eject "$DEVICE" &>'/dev/null'; then echo -e '\nDevice ejected'
			else echo -e '\nErr: Cant eject device'
				exit 1
			fi
		else echo -e "\nError flashing $ISOFILE to $DEVICE"
			exit 1
		fi
	elif [ "$ANS" == 'n' ]; then echo -e '\nOperation cancelled'
	fi
}

check_pv_inst(){
	if ! command -v pv &>'/dev/null'; then
		echo -e '\nPv isnt installed, installing it now\n'
		if ! sudo pacman -S pv --noconfirm; then
			echo -e '\nFailed to install Pv with pacman, installing it manually from repository\n'
			PKGURL='https://geo.mirror.pkgbuild.com/extra/os/x86_64/pv-1.8.9-1-x86_64.pkg.tar.zst'
			FLNM="$HOME/Downloads/pv-1.8.9-1-x86_64.pkg.tar.zst"
			wget -c -P "$HOME/Downloads" "$PKGURL"
			sudo pacman -U "$FLNM" --noconfirm
		fi
	fi
}

echo -e "\nEnter the iso path eg. '$DEFDIR'\n"
read -rep '- ' ISODIR
[ ! -d "$ISODIR" ] && echo -e "\nError: ISO directory '$ISODIR' does not exist" && exit 1
[ -z "$ISOFILE" ] && echo -e '\nErr: Cant find iso file' && exit 1
check_pv_inst && select_drive && write_iso