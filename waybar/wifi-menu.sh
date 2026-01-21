#!/bin/bash

get_wifi_networks() {
    nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | sort -t: -k2 -nr
}

connect_to_network() {
    local ssid="$1"
    local security="$2"
    
    if [ "$security" = "--" ]; then
        nmcli device wifi connect "$ssid"
    else
        nmcli device wifi connect "$ssid" --ask
    fi
}

toggle_wifi() {
    local status=$(nmcli radio wifi)
    if [ "$status" = "enabled" ]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

networks=$(get_wifi_networks)
if [ -z "$networks" ]; then
    notify-send "WiFi" "No networks found"
    exit 1
fi

options=""
while IFS=: read -r ssid signal security; do
    if [ -n "$ssid" ]; then
        icon="[🔒]"
        [ "$security" = "--" ] && icon="[🔓]"
        options="$options$ssid $icon ($signal%)\n"
    fi
done <<< "$networks"

options="${options}---\n📡 Toggle WiFi\n🔄 Rescan"
chosen=$(echo -e "$options" | head -n -1 | hyprlauncher -dmenu -p "WiFi Network:")

case "$chosen" in
    *"Toggle WiFi"*)
        toggle_wifi
        ;;
    *"Rescan"*)
        nmcli device wifi rescan
        notify-send "WiFi" "Rescanning for networks..."
        ;;
    *)
        ssid=$(echo "$chosen" | sed 's/ \[.*\].*//')
        [ -n "$ssid" ] && connect_to_network "$ssid"
        ;;
esac
