#!/bin/bash

# Path to the configuration file
CONFIG_FILE="/etc/biosense/setup-modem.conf"

# Function to read APN from the configuration file
read_apn() {
    local apn=""
    if [ -f "$CONFIG_FILE" ]; then
        apn=$(grep -i 'apn' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs) # Extract APN value
    fi
    echo "$apn"
}

# Detect the modem interface (e.g., wwan0)
modem_iface=$(nmcli dev status | grep gsm | awk '{print $1}')

# Read APN from the configuration file
APN=$(read_apn)

if [ -n "$modem_iface" ]; then
    if [ -n "$APN" ]; then
        nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" gsm.apn "$APN" ipv4.method auto &&
            echo "Added LTE modem connection with APN: $APN" ||
            echo "Failed to add LTE modem connection with APN: $APN"
    else
        nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" ipv4.method auto &&
            echo "Added LTE modem connection without APN" ||
            echo "Failed to add LTE modem connection without APN"
    fi

    nmcli c modify lte connection.autoconnect yes &&
        echo "Set LTE connection to autoconnect" ||
        echo "Failed to set LTE connection to autoconnect"
else
    echo "No modem network interface found."
fi
