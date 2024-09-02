#!/bin/bash

# Define the vendor MAC address prefixes to filter
VENDOR_PREFIXES=(
  "50:2b:73" # Tenda U12
  "c8:fe:0f" # BL-R8812-AF1
)

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

# Function to check if an interface's MAC address matches the vendor prefixes
matches_vendor_prefix() {
    local mac_address=$1
    for prefix in "${VENDOR_PREFIXES[@]}"; do
        if [[ $mac_address == $prefix* ]]; then
            return 0  # Match found
        fi
    done
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
        # Check if the MAC address matches any of the vendor prefixes
        if matches_vendor_prefix $mac_address; then
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