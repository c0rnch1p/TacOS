#!/bin/bash

REPODIR='arco_upstream'
REPOURL='https://github.com/arconetpro/arcopro-iso.git'

cleanup(){
	sudo rm -rf "$REPODIR"
}

if [ ! "$(command -v bat)" ]; then
	echo '⚠ bat not installed ⚠' & exit 0
fi

read -rp "Check $REPOURL? ▸ " ANS
if [[ -z "$REPOURL" || "$ANS" =~ ^(0|n|na|no|nu|al).* ]]; then
	read -rp 'URL ▸ ' REPOURL
	sed -i "4s|REPOURL='[^']*'|REPOURL='$REPOURL'|" 'check_arco.sh'
fi

(
	trap SIGTSTP && cleanup
	git clone --quiet "$REPOURL" "$REPODIR"
	cd "$REPODIR" || exit 1
	COMMITRANGE=$(git rev-list HEAD)
	git fetch
	for COMMIT in ${COMMITRANGE}; do
		git show "$COMMIT" |
			bat --file-name "$REPOURL"\
				--style grid,header-filename\
				-l diff --theme ansi
	done
)

