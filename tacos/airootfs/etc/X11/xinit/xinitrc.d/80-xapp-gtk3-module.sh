#!/bin/bash
if [ -z "$GTK3_MODULES" ]; then
	GTK3_MODULES="libxapp-gtk3-module.so"
else
	GTK3_MODULES="$GTK3_MODULES:libxapp-gtk3-module.so"
fi
export GTK3_MODULES
