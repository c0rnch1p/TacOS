#!/bin/bash
#shellcheck disable=SC2162

BUILDDATE=$(date +'%H%M-%d%m-%Y')
OSNAME='tacos'
OUTFOLDER='iso_out'
VERSION='v1.5'
WORKDIR='build'

declare -A PACKAGEURLS=(
	['archiso']='https://geo.mirror.pkgbuild.com/extra/os/x86_64/archiso-77-1-any.pkg.tar.zst'
	['arcolinux-keyring']='https://ant.seedhost.eu/arcolinux/arcolinux_repo/x86_64/arcolinux-keyring-20251209-3-any.pkg.tar.zst'
	['arcolinux-mirrorlist-git']='https://ant.seedhost.eu/arcolinux/arcolinux_repo/x86_64/arcolinux-mirrorlist-git-24.03-12-any.pkg.tar.zst'
	['chaotic-keyring']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/chaotic-keyring-20230616-1-any.pkg.tar.zst'
	['chaotic-mirrorlist']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/chaotic-mirrorlist-20240306-1-any.pkg.tar.zst'
	['endeavouros-keyring']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/endeavouros-keyring-20231222-1-any.pkg.tar.zst'
	['endeavouros-mirrorlist']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/endeavouros-mirrorlist-24.3-1-any.pkg.tar.zst'
	['pacman-contrib']='https://geo.mirror.pkgbuild.com/extra/os/x86_64/pacman-contrib-1.10.5-1-x86_64.pkg.tar.zst'
	['rebornos-keyring']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/rebornos-keyring-20231128-1-any.pkg.tar.zst'
	['rebornos-mirrorlist']='https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64/rebornos-mirrorlist-20240503-1-any.pkg.tar.zst'
	['reflector']='https://geo.mirror.pkgbuild.com/extra/os/x86_64/reflector-2023-2-any.pkg.tar.zst'
)

clean_workdir(){
	[ -d "$OUTFOLDER" ] && sudo rm -rf "$OUTFOLDER"
	[ -d "$HOME/$OUTFOLDER" ] && sudo rm -rf "$HOME/$OUTFOLDER"
	[ ! -d "$HOME/Downloads" ] && mkdir -p "$HOME/Downloads"
}

select_ingredients(){
	while true; do
		echo -e '\nSelect the ingredients for the TacOS'
		echo -e '- [J] Jalapenos (Intel)\n- [A] Asados (AMD)\n- [N] Nachos (Nvidia)\n- [C] Churros (Server)\n'
		read -p '- ' GPUBRAND
		case "$GPUBRAND" in
			j|J) PACKAGELIST='jalapenos.txt'
				LATESTISO="${OSNAME}-${VERSION}-jalapenos-x86_64"
				ISOLABEL="${OSNAME}-${VERSION}-jalapenos-x86_64.iso"
				cp "pkglists/$PACKAGELIST" "$PWD/tacos/packages.x86_64"
				break;;
			a|A) PACKAGELIST='asados.txt'
				LATESTISO="${OSNAME}-${VERSION}-asados-x86_64"
				ISOLABEL="${OSNAME}-${VERSION}-asados-x86_64.iso"
				cp "pkglists/$PACKAGELIST" "$PWD/tacos/packages.x86_64"
				break;;
			n|N) PACKAGELIST='nachos.txt'
				LATESTISO="${OSNAME}-${VERSION}-nachos-x86_64"
				ISOLABEL="${OSNAME}-${VERSION}-nachos-x86_64.iso"
				cp "pkglists/$PACKAGELIST" "$PWD/tacos/packages.x86_64"
				break;;
			c|C) PACKAGELIST='churros.txt'
				LATESTISO="${OSNAME}-${VERSION}-churros-x86_64"
				ISOLABEL="${OSNAME}-${VERSION}-churros-x86_64.iso"
				cp "pkglists/$PACKAGELIST" "$PWD/tacos/packages.x86_64"
				break;;
			*) echo -e '\n⚠ invalid selection ⚠';;
		esac
	done
}

chk_curl_and_wget(){
	if command -v curl &>'/dev/null'; then DLCMD=('curl' '-L' '-o')
	elif command -v wget &>'/dev/null'; then DLCMD=('wget' '-c' '-O')
	else echo -e '\nNeither wget nor curl is installed, please install one to continue'
		exit 1
	fi
}

chk_pacman_reqs(){
	echo -e '\nMaking sure system requirements are installed'
	for PACKAGE in "${!PACKAGEURLS[@]}"; do
		if ! pacman -Qs "$PACKAGE" &>'/dev/null'; then echo -e "\n$PACKAGE isnt installed, installing it now\n"
			if ! sudo pacman -S "$PACKAGE"; then echo -e "\nFailed to install $PACKAGE with pacman, installing it manually from repository\n"
				case "$PACKAGE" in
					'archiso') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['archiso']##*/}" "${PACKAGEURLS['archiso']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['archiso']##*/}";;
					'arcolinux-keyring') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['arcolinux-keyring']##*/}" "${PACKAGEURLS['arcolinux-keyring']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['arcolinux-keyring']##*/}";;
					'arcolinux-mirrorlist-git') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['arcolinux-mirrorlist-git']##*/}" "${PACKAGEURLS['arcolinux-mirrorlist-git']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['arcolinux-mirrorlist-git']##*/}";;
					'chaotic-keyring') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['chaotic-keyring']##*/}" "${PACKAGEURLS['chaotic-keyring']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['chaotic-keyring']##*/}";;
					'chaotic-mirrorlist') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['chaotic-mirrorlist']##*/}" "${PACKAGEURLS['chaotic-mirrorlist']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['chaotic-mirrorlist']##*/}";;
					'endeavouros-keyring') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['endeavouros-keyring']##*/}" "${PACKAGEURLS['endeavouros-keyring']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['endeavouros-keyring']##*/}";;
					'endeavouros-mirrorlist') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['endeavouros-mirrorlist']##*/}" "${PACKAGEURLS['endeavouros-mirrorlist']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['endeavouros-mirrorlist']##*/}";;
					'pacman-contrib') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['pacman-contrib']##*/}" "${PACKAGEURLS['pacman-contrib']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['pacman-contrib']##*/}";;
					'rebornos-keyring') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['rebornos-keyring']##*/}" "${PACKAGEURLS['rebornos-keyring']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['rebornos-keyring']##*/}";;
					'rebornos-mirrorlist') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['rebornos-mirrorlist']##*/}" "${PACKAGEURLS['rebornos-mirrorlist']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['rebornos-mirrorlist']##*/}";;
					'reflector') "${DLCMD[@]}" "$HOME/Downloads/${PACKAGEURLS['reflector']##*/}" "${PACKAGEURLS['reflector']}"
						sudo pacman -U "$HOME/Downloads/${PACKAGEURLS['reflector']##*/}";;
				esac
			fi
		fi
	done
}

chk_pacman_conf(){
	if ! diff -q 'tacos/pacman.conf' '/etc/pacman.conf'; then
		echo -e '\nCopy over new pacman.conf to /etc [y/n]\n'
		read -p '- ' ANS
		[[ "$ANS" =~ ^(1|y|ya|ye|ta|ok|pl|th).* ]] && sudo cp 'tacos/pacman.conf' '/etc'
	fi
}

chk_pacman_keys(){
	echo -e '\nUpdating pacman mirrors and keyrings\n'
	sudo pacman-key --init
	sudo pacman-key --populate archlinux
	sudo reflector --age 6 --latest 20 --sort score --protocol https --save '/etc/pacman.d/mirrorlist'
	sudo pacman -Fy; sudo pacman -Syu
	sed -i "s/\(^ISO_BUILD=\).*/\1$BUILDDATE/" 'tacos/airootfs/etc/dev-rel'
	echo -e "\nAdded build date ($BUILDDATE) to /etc/dev-rel"
}

# grub-install error: Failed to get canonical path of /boot/efi
# Potentially due to the directory being currently encrypted
# with LVM or some other cryptsetup tool, probably not an issue
# - $BROWSER https://bbs.archlinux.org/viewtopic.php?id=243226

build_iso(){
	cleanup_failure(){
		echo -e '\nAn error occurred, cleaning up build directories'
		sudo rm -rf "$WORKDIR" "$LATESTISO.tar.gz"
		echo -e '\nPlease check the package lists and configuration before retrying'
		exit 1
	}
	echo "\nBuilding iso from archiso template with packages listed in $PACKAGELIST"
	sudo mkarchiso -v -w "$WORKDIR" -o "$OUTFOLDER" "$PWD/tacos/" || cleanup_failure
	cd "$OUTFOLDER" || exit 1
	sudo mv 'tacos-'*'-x86_64.iso' "$ISOLABEL"
	echo -e "\nCreating checksums for $ISOLABEL\n"
	md5sum "$ISOLABEL" | sudo tee "$ISOLABEL.md5"
	sha1sum "$ISOLABEL" | sudo tee "$ISOLABEL.sha1"
	sha256sum "$ISOLABEL" | sudo tee "$ISOLABEL.sha256"
	ls -la && cd - || exit 1
}

make_archive(){
	cleanup_success(){
		sudo rm -rf "$LATESTISO" "$WORKDIR"
		echo -e "\nFresh iso in $OUTFOLDER"
	}
	sudo chown "$USER":"$USER" "$OUTFOLDER"
	sudo find "$OUTFOLDER" -type f -exec chown "$USER":"$USER" {} \;
	echo -e '\nCreate an iso archive? [y/n]\n'
	read -p '- ' ANS
	[[ "$ANS" =~ ^(1|y|ya|ye|ta|ok|pl|th).* ]] && tar cvf "$LATESTISO.tar" "$OUTFOLDER"
	cleanup_success
}

if [ -n "$1" ]; then "$1"
else
	clean_workdir
	select_ingredients
	chk_curl_and_wget
	chk_pacman_reqs
	chk_pacman_conf
	chk_pacman_keys
	build_iso
	make_archive
fi