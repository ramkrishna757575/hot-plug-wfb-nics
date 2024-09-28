#!/bin/bash

# Initialize log file and type variables
LOG_FILE=""
TYPE=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --log)
        LOG_FILE="$2"
        shift
        ;;
    --type)
        TYPE="$2"
        shift
        ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

# Initialize an empty string to store matching interface names
matching_interfaces=""

# List all network interfaces and filter only wireless ones
for iface in /sys/class/net/*; do
    iface_name=$(basename $iface)
    # Check if the interface is wireless and usb
    if [ -d "/sys/class/net/$iface_name/wireless" ] && [[ "$(readlink -f /sys/class/net/$iface_name/device/subsystem)" == *"usb"* ]]; then
        # Get the MAC address of the interface
        mac_address=$(cat /sys/class/net/$iface_name/address)
        # Append the interface name to the list
        matching_interfaces+="$iface_name "
    fi
done

# Output the list of matching interfaces as a space-separated string
new_wfb_nics="WFB_NICS=\"${matching_interfaces% }\""

# Read the current contents of /etc/default/wifibroadcast
current_wfb_nics=$(cat /etc/default/wifibroadcast 2>/dev/null)

# Compare and update if different
if [[ "$current_wfb_nics" != "$new_wfb_nics" ]]; then
    echo "$new_wfb_nics" >/etc/default/wifibroadcast
    systemctl restart wifibroadcast &
    # Log to file if --log argument was provided
    if [[ -n "$LOG_FILE" ]]; then
        echo "$(date) [$TYPE]: Network interface $ACTION $INTERFACE" >>"$LOG_FILE"
        echo "$(date) [$TYPE]: $new_wfb_nics" >>"$LOG_FILE"
        echo "$(date) [$TYPE]: Restarting Wifibroadcast service" >>"$LOG_FILE"
    fi
fi