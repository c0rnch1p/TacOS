#!/bin/bash
#shellcheck disable=SC2086

OLDVSN='v1.5'

[ "$(basename "$PWD")" = 'scripts' ] && cd .. || exit 1
[ "$(basename "$PWD")" != 'TacOS' ] && echo -e '\nPlease change to the TacOS directory'

echo -e "\nThe current iso version is ${OLDVSN}"
echo -e '\nEnter the new iso version\n'
read -rp '- ' NEWVSN

echo -e '\nChanging version refs in archiso files'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'build_iso.sh'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'readme.md'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'tacos/airootfs/etc/calamares/branding/TacOS/branding.desc'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'tacos/airootfs/etc/dev-rel'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'tacos/airootfs/etc/hostname'
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' 'tacos/profiledef.sh'

echo -e "Iso version updated to ${NEWVSN}"
sed -i 's/'"${OLDVSN}"'/'"${NEWVSN}"'/gI' "scripts/$0" # This file