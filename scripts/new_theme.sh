#!/bin/bash

THEME_FILES=(
	'../tacos/airootfs/etc/default/grub'
	'../tacos/airootfs/etc/DIR_COLORS'
	'../tacos/airootfs/etc/htoprc'
	'../tacos/airootfs/etc/nanorc'
	#'../tacos/airootfs/etc/skel/.config/awesome/configs/conky.conf'
	'../tacos/airootfs/etc/skel/.config/awesome/configs/rofi.rasi'
	'../tacos/airootfs/etc/skel/.config/awesome/rc.lua'
	'../tacos/airootfs/etc/skel/.config/awesome/themes/tacos.lua'
	'../tacos/airootfs/etc/skel/.config/fonts.conf'
	'../tacos/airootfs/etc/skel/.config/gtk-2.0/gtkrc'
	'../tacos/airootfs/etc/skel/.config/gtk-3.0/settings.ini'
	'../tacos/airootfs/etc/skel/.config/neofetch/config.conf'
	'../tacos/airootfs/etc/skel/.config/terminator/config'
	'../tacos/airootfs/etc/skel/.config/Trolltech.conf'
	'../tacos/airootfs/usr/share/icons/default/index.theme'
)

unset GRAPHICAL
echo -e '\nSet graphical editor'
echo -e '- [1] Geany'
echo -e '- [2] Gedit\n'
read -rep '- ' ANS
if [ "$ANS" == "1" ]; then export GRAPHICAL='/usr/bin/geany --no-session'
elif [ "$ANS" == "2" ]; then export GRAPHICAL='/usr/bin/gedit'
fi; $GRAPHICAL "${THEME_FILES[@]}"