#!/bin/bash

URLS=(
	'https://geo.mirror.pkgbuild.com/extra/os/x86_64'
	'https://ant.seedhost.eu/arcolinux/arcolinux_repo/x86_64'
	'https://ant.seedhost.eu/arcolinux/arcolinux_repo_3party/x86_64'
)

for URL in "${URLS[@]}"
do
    "$BROWSER" "$URL"
done
