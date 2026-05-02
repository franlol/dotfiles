#!/bin/sh

current=$(powerprofilesctl get 2>/dev/null)

case "$current" in
    power-saver)
        next="balanced"
        ;;
    balanced)
        next="performance"
        ;;
    performance)
        next="power-saver"
        ;;
    *)
        next="balanced"
        ;;
esac

powerprofilesctl set "$next"
pkill -USR1 -f '/waybar/battery-status.sh$' 2>/dev/null || true
