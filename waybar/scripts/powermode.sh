#!/bin/bash

# Power Profile Cycling Script for Waybar
# Cycles through: power-saver → balanced → performance → power-saver
# Uses D-Bus interface to power-profiles-daemon (no authentication required)

PROFILES=("power-saver" "balanced" "performance")
ICONS=("󰌪" "󰓦" "󰾅")
NAMES=("Eco" "Balanced" "Turbo")

# Function to get current profile via D-Bus
get_current_profile() {
    local profile
    profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | grep -o '"[^"]*"' | tr -d '"')
    
    if [[ -n "$profile" ]]; then
        echo "$profile"
    else
        echo "balanced"  # fallback
    fi
}

# Function to set profile via D-Bus (no authentication required)
set_profile() {
    local profile="$1"
    busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$profile" 2>/dev/null
    return $?
}

# Function to format output consistently
format_output() {
    local icon="$1"
    local name="$2"
    local class="$3"
    printf '{"text": "<span>%s</span> %s", "tooltip": "Power Mode: %s", "class": "%s"}' \
        "$icon" "$name" "$name" "$class"
}

# Function to get profile index
get_profile_index() {
    local profile="$1"
    for i in "${!PROFILES[@]}"; do
        if [[ "${PROFILES[$i]}" == "$profile" ]]; then
            echo $i
            return
        fi
    done
    echo 1  # Default to balanced if not found
}

# Check if we're in click mode (argument provided) or exec mode
if [[ "$1" == "--click" ]]; then
    # Click mode: cycle to next profile
    current=$(get_current_profile)
    current_index=$(get_profile_index "$current")
    next_index=$(((current_index + 1) % 3))
    
    next_profile="${PROFILES[$next_index]}"
    
# Try to set the new profile
    if set_profile "$next_profile"; then
        format_output "${ICONS[$next_index]}" "${NAMES[$next_index]}" "$next_profile"
    else
        format_output "${ICONS[$current_index]}" "${NAMES[$current_index]}" "$current"
    fi
else
    # Exec mode: just show current status
    current=$(get_current_profile)
    current_index=$(get_profile_index "$current")
    
    format_output "${ICONS[$current_index]}" "${NAMES[$current_index]}" "$current"
fi
