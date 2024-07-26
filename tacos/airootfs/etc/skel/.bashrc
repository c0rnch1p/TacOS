#!/bin/bash
#shellcheck disable=SC1091, SC2143
# 100x
#                               _ )    \     __|  |  |  _ \   __|
#                               _ \   _ \  \__ \  __ |    /  (
#                              ___/ _/  _\ ____/ _| _| _|_\ \___|
#
#===================================================================================================
#
# Files:
# - Filepath: $HOME/.bashrc
#
#===================================================================================================
#
# Resources:
# - GNU.org: $BROWSER https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
#===================================================================================================
#
# Referecnes:
# - Bash Manpage: man -P 'less +79 +/INVOCATION' 'bash(1)'
#
#===================================================================================================
# - [1] Initialize Shell
#===================================================================================================

# General setup
mesg y &>'/dev/null'
unicode_start &>'/dev/null'
export BIN="$HOME/.local/bin"
export HOSTNAME=$(cat /etc/hostname)
. '/usr/share/bash-completion/bash_completion'

# Enable completions for read
comp_func(){
	local COMPREPLY
	COMPREPLY=$(compgen -W "$2" -- "${COMP_WORDS[COMP_CWORD]}")
}; complete -F comp_func read

# Check if using vbox and run vboxservice
if [[ -f '/sys/hypervisor/uuid' ]]; then
	HYPEVISUID=$(cat '/sys/hypervisor/uuid')
	if [[ "$HYPEVISUID" != "00000000-0000-0000-0000-000000000000" ]]; then
		sed -i "s/#'vboxservice'/'vboxservice'/" "$BIN/conf_daemons"
	fi
fi

# Source files, order matters
BIN_SCRIPTS=(
	"$BIN/conf_variables" # Vars config
	"$BIN/conf_aliases" # Alias config
	"$BIN/05_permissions"
	"$BIN/conf_perso" # Personal config
	"$BIN/conf_speeddial" # Speeddial config
	"$BIN/conf_daemons" # Daemons config
	"$BIN/conf_cleanup" # Cleanup config
	"$BIN/conf_insulter"
	"$BIN/mountmgr"
)

for FILE in "${BIN_SCRIPTS[@]}"; do
	[ -f "$FILE" ] && . "$FILE"
done

# Enable terminal color support and customization
if [ "$USECOLOR" == 'true' ]; then
	if test -f '/etc/DIR_COLORS' && type -P dircolors &>'/dev/null'; then
		export LS_COLORS=''
		funkydirs(){
			'/usr/bin/dircolors' -b '/etc/DIR_COLORS' |\
			sed -e "s/LS_COLORS='//g" -e 's/export LS_COLORS//g' |\
			sed -e "s/.ucf-old=38;2;255;177;82;2:';/.ucf-old=38;2;255;177;82;2:/g" |\
			tr -d '[:space:]'
		}
		funkydirs > "$HOME/.dircolors"
		LS_COLORS=$(cat "$HOME/.dircolors")
	fi
fi

# Set the prompt command based on the terminal type
case "$TERM" in
	'alacritty' | 'ansi' | 'color-xterm' | 'con'* | 'cygwin' | 'dtterm' | 'dvtm'* | 'Eterm'\
	| 'eterm-color' | 'fbterm' | 'gnome'* | 'hurd' | 'interix' | 'jfbterm' | 'konsole'* | 'kterm'\
	| 'linux'* | 'mach'* | 'mlterm' | 'putty'* | 'rxvt'* | 'st'* | 'term'* | 'vt100' | 'xterm'*)
		PROMPT_COMMAND='nter_shot; echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"';;
	'screen'*)
		PROMPT_COMMAND='nter_shot; echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"';;
esac

# Set the prompt style based on user or root
if [[ "$EUID" == 0 || $(tty | grep '/dev/tty') ]]; then
	PS1='\[\e[01;31m\][\h\[\e[01;36m\] \W\[\e[01;31m\]]\$\[\e[00m\] '
else echo -e "$(tput bold)\e[38;2;162;226;2m$USER ⩜ $HOSTNAME"
	PS1='\[\e[38;2;162;226;2m\][\[\e[38;2;228;255;0;1m\]\W\[\e[38;2;162;226;2m\]]\$\[\e[00m\] '
fi

#===================================================================================================
# - [2] Useful Functions
#===================================================================================================

# Draw borders around function output
draw_border(){
	local BORDER_CHAR=$1
	local OUTCMD=$2
	local TCOLS SCOLS MCOLS
	"$OUTCMD" >'/tmp/dump' 2>&1
	TCOLS=$(wc -L < /tmp/dump)
	SCOLS=$(tput cols)
	MCOLS=$(( TCOLS / 2 ))
	if [ $TCOLS -lt $SCOLS ]; then tput setaf 5
		for _ in $(seq 1 $MCOLS); do echo -n "$BORDER_CHAR"
		done; echo; tput sgr0
	fi
}

# Recursively remove backup files
fuckem(){
	find . -name "*.save" -exec rm -f {} \;
	find . -name "*.bak" -exec rm -f {} \;
	find . -name "*~" -exec rm -f {} \;
	echo "*fuckem*"
}

# Audible gunshot when entering a command
nter_shot(){
	local PID
	(mpv --volume=30 --really-quiet "$BIN/shot.wav" &>'/dev/null' &&
		PID=$? && kill -9 $PID &>'/dev/null' &)
}

# Audible gun reload when reloading the shell
reload(){
	mpv --volume=40 --really-quiet "$BIN/reload.wav" &>'/dev/null'
	kill -9 "$(echo $$)" # kill parent
}

# Grep for processes in extended ps output
psgrep(){
	command pgrep "$@" &>'/dev/null' &&
		echo 'USR          PID     SID     GID  CPU  MEM RTM      STT  CMD'
		ps --forest -eo user,pid,sid,pgid,%cpu,%mem,time,stat,comm | grep --color=always -i "$@"
}

# List package depends or programs that depend on it
depends(){
	deps_body(){
		pacman -Sii "$SRCH" | grep Depends | cut -d' ' -f7-50 |
		cut -d':' -f2 | tr ' ' '\n' | sed '/^$/d' | sed 's/^/ ▸ /' | grep -v '.so'
	}
	reqs_body(){
		pacman -Sii "$SRCH" | grep Required | cut -d' ' -f7-50 |
		cut -d':' -f2 | tr ' ' '\n' | sed '/^$/d' | sed 's/^/ ▸ /' | grep -v '.so'
	}
	if [[ $# -ge 2 && "$1" =~ ^(r|-r|--requirements|--reverse)$ ]]; then
		SRCH="$2"; OUTCMD="reqs_body"
	else SRCH="$1"; OUTCMD="deps_body"
	fi
	draw_border "⩝⩜" "$OUTCMD"; "$OUTCMD"
	draw_border "⩜⩝" "$OUTCMD"
}

# Get DeadBeef track metadata
get_dead(){
	ded(){
		deadbeef --nowplaying " | ARTIST: %a" | tr '[:lower:]' '[:upper:]' &>>'file' && echo >>'file'
		deadbeef --nowplaying " | ALBUM: %b" | tr '[:lower:]' '[:upper:]' &>>'file' && echo >>'file'
		deadbeef --nowplaying " | TRACK: %t" | tr '[:lower:]' '[:upper:]' &>>'file' && echo >>'file'
	}; ded &>'/dev/null'
	cat 'file' | grep 'ARTIST'
	cat 'file' | grep 'ALBUM'
	cat 'file' | grep 'TRACK'
	rm 'file' & exit 0
}

# Get curdir stats
ino(){
	[[ ! -n "$1" && ! "$1" =~ ^(q|-q|--quiet)$ ]] && echo && ls -A | tr ' ' '\n'
	TITEMS=$(ls -A | wc -l)
	TFILES=$(find . -maxdepth 1 -type f | wc -l)
	TFOLDERS=$(ls -d */ 2>/dev/null | wc -l)
	echo -e "\n\033[92mTotal Items:$(tput bold) $TITEMS\033[0m"
	echo -e "\033[92mFiles/Folders:$(tput bold) $TFILES:$TFOLDERS\033[0m\n"
}

#===================================================================================================
# - [3] Live System Message
#===================================================================================================

if command grep -q 'live' '/etc/group'; then
	if [[ "$(tty)" == '/dev/tty1' && ! -f '/tmp/sysmsg.lock' ]]; then
		echo -e '\n| The graphical environment is launched with <startx>'
		echo -e '| The system can be installed with <calamares>'
		echo -e '| Once installed please run <01_run_all>\n|'
		echo -e '| Before doing so, be sure to add the newly created'
		echo -e '| user to the sudoers file (root login required)\n|'
		echo -e "| If the 'share/xorg/Xorg.0.log' error is present,"
		echo -e '| please refresh the shell with <bash>\n|'
		echo -e '| Welcome to TacOS have fun!\n'
		echo '*click*' >'/tmp/sysmsg.lock'
	fi
fi