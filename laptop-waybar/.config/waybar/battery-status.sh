#!/bin/sh

bat_path=$(printf '%s\n' /sys/class/power_supply/BAT* | awk 'NR==1 { print; exit }')
display_device="/org/freedesktop/UPower/devices/DisplayDevice"
sleep_pid=""

interrupt_sleep() {
    if [ -n "$sleep_pid" ]; then
        kill "$sleep_pid" 2>/dev/null || true
    fi
}

trap 'interrupt_sleep' USR1

escape_json() {
    printf '%s' "$1" | awk 'BEGIN { ORS = "" } { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\r/, "\\r"); gsub(/\n/, "\\n"); print }'
}

read_file() {
    file="$1"
    [ -r "$file" ] || return 1
    IFS= read -r value < "$file" || return 1
    printf '%s' "$value"
}

get_icon() {
    percentage="$1"
    state="$2"

    if [ "$state" = "charging" ]; then
        icons="󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅"
    else
        icons="󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹"
    fi

    printf '%s\n' "$icons" | awk -v pct="$percentage" '
        {
            split($0, arr, " ")
            count = length(arr)
            idx = int((pct * count) / 101) + 1
            if (idx < 1) idx = 1
            if (idx > count) idx = count
            print arr[idx]
        }
    '
}

get_level_class() {
    percentage="$1"

    if [ "$percentage" -le 15 ]; then
        printf 'critical'
    elif [ "$percentage" -le 30 ]; then
        printf 'warning'
    else
        printf 'good'
    fi
}

emit_json() {
    percentage="$1"
    state="$2"
    tooltip="$3"

    icon=$(get_icon "$percentage" "$state")
    level_class=$(get_level_class "$percentage")
    text=$(escape_json "$icon $percentage%")

    if [ -n "$tooltip" ]; then
        tooltip=$(escape_json "$tooltip")
        printf '{"text":"%s","tooltip":"%s","class":["%s","%s"]}\n' "$text" "$tooltip" "$level_class" "$state"
    else
        printf '{"text":"%s","class":["%s","%s"]}\n' "$text" "$level_class" "$state"
    fi
}

read_fast_state() {
    if [ ! -d "$bat_path" ]; then
        fast_percentage=0
        fast_state="unknown"
        return
    fi

    fast_percentage=$(read_file "$bat_path/capacity")
    fast_status=$(read_file "$bat_path/status")

    [ -n "$fast_percentage" ] || fast_percentage=0
    [ -n "$fast_status" ] || fast_status="Unknown"

    fast_state=$(printf '%s' "$fast_status" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
}

read_tooltip_state() {
    info=$(upower -i "$display_device" 2>/dev/null)
    profile=$(powerprofilesctl get 2>/dev/null)

    if [ -z "$info" ]; then
        tooltip_text="Profile: ${profile:-unknown}"
        return
    fi

    get_value() {
        printf '%s\n' "$info" | awk -F: -v key="$1" '$1 ~ key { sub(/^[ \t]+/, "", $2); print $2; exit }'
    }

    tooltip_time=$(get_value "time to empty")
    if [ -z "$tooltip_time" ]; then
        tooltip_time=$(get_value "time to full")
    fi
    if [ -z "$tooltip_time" ]; then
        tooltip_time="N/A"
    fi

    tooltip_power=$(get_value "energy-rate")
    if [ -z "$tooltip_power" ]; then
        tooltip_power="N/A"
    fi

    if [ -z "$profile" ]; then
        profile="unknown"
    fi

    tooltip_text=$(printf 'Time: %s\rPower: %s\rProfile: %s' "$tooltip_time" "$tooltip_power" "$profile")
}

while :; do
    read_fast_state
    emit_json "$fast_percentage" "$fast_state" ""

    read_tooltip_state
    emit_json "$fast_percentage" "$fast_state" "$tooltip_text"

    sleep 15 &
    sleep_pid=$!
    wait "$sleep_pid" 2>/dev/null || true
    sleep_pid=""
done
