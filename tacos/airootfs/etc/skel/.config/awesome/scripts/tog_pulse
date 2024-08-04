#!/bin/bash

amixer sset 'Master' on
pgrep -x 'pulseaudio' >'/dev/null' && pulseaudio --kill
sleep 1 && pulseaudio --start
notify-send 'PulseAudio' 'Pulse restarted'