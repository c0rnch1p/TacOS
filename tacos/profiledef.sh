#!/bin/bash
#shellcheck disable=SC2034
#80x
#             _ \  _ \   _ \   __| _ _|  |     __|  _ \  __|  __|
#             __/    /  (   |  _|    |   |     _|   | |  _|   _|
#            _|   _|_\ \___/  _|   ___| ____| ___| ___/ ___| _|
#
#===============================================================================
#
# Files:
# - Filepath: /usr/share/archiso/config/releng/profiledef.sh
# - Readme: /usr/share/doc/archiso/README.profile.rst
#
#===============================================================================
#
# Resources:
# - Archiso Arch Wiki: $BROWSER https://wiki.archlinux.org/title/Archiso
#
#===============================================================================
iso_name='tacos'
iso_label='tacos_v1.5'
iso_publisher='tacos <https://github.com/c0rnch1p>'
iso_application='tacos Live Disk Image'
iso_version='v1.5'
install_dir='arch'
buildmodes=('iso')
bootmodes=(
	'bios.syslinux.mbr'
	'bios.syslinux.eltorito'
	'uefi-ia32.grub.esp'
	'uefi-x64.grub.esp'
	'uefi-ia32.grub.eltorito'
	'uefi-x64.grub.eltorito'
)
arch='x86_64'
pacman_conf='pacman.conf'
airootfs_image_type='squashfs'
airootfs_image_tool_options=(-comp xz -Xbcj x86 -b 1M -Xdict-size 1M)
bootstrap_tarball_compression=(zstd -c -T0 --auto-threads=logical --long -19)
file_permissions=(
	# Folder mask default: 755 (rwxr-xr-x)
	['/etc/gshadow']='0:0:600'
	['/etc/shadow']='0:0:600'
	['/etc/sudoers.d']='0:0:700'
	['/etc/wireguard']='0:0:700'
	# File mask default: 644 (rw-rw-r--)
	['/etc/X11/xinit/xinitrc.d/80-xapp-gtk3-module.sh']='0:0:755'
	['/usr/local/bin/arcolinux-snapper']='0:0:755'
)