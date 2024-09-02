#!/bin/bash

# Define the MAC address prefix to exclude (Internal Wifi adapter)
EXCLUDE_PREFIX="98:03:cf"

# Initialize log file variable
LOG_FILE=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --log) LOG_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Function to check if an interface's MAC address matches the exclude prefix
matches_exclude_prefix() {
    local mac_address=$1
    if [[ $mac_address == $EXCLUDE_PREFIX* ]]; then
        return 0  # Match found
    fi
    return 1  # No match
}

# Initialize an empty string to store matching interface names
matching_interfaces=""

# List all network interfaces and filter only wireless ones
for iface in /sys/class/net/*; do
    iface_name=$(basename $iface)
    # Check if the interface is wireless
    if [ -d "/sys/class/net/$iface_name/wireless" ]; then
        # Get the MAC address of the interface
        mac_address=$(cat /sys/class/net/$iface_name/address)
        # Check if the MAC address does not match the exclude prefix
        if ! matches_exclude_prefix $mac_address; then
            # Append the interface name to the list
            matching_interfaces+="$iface_name "
        fi
    fi
done

# Output the list of matching interfaces as a space-separated string
echo "WFB_NICS=\"${matching_interfaces% }\""

# Log to file if --log argument was provided
if [[ -n "$LOG_FILE" ]]; then
    echo "$(date): Network interface $ACTION $INTERFACE" >> "$LOG_FILE"
    echo "$(date): WFB_NICS \"${matching_interfaces% }\"" >> "$LOG_FILE"
fi

# Trim trailing space (if any) and write to /etc/default/wifibroadcast
echo "WFB_NICS=\"${matching_interfaces% }\"" > /etc/default/wifibroadcast

# Restart wifibroadcast service if it is already running
systemctl restart wifibroadcast &