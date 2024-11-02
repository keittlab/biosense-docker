#!/bin/bash

#nmcli add type gsm ifname wwan0 connection.interface-name "cdc-wdm0" con-name "lte" gsm.apn "iot.1nce.net" ipv4.method auto
#nmcli up "lte"

# Path to the configuration file
CONFIG_FILE="/etc/biosense/setup-modem.conf"

# Read values from the configuration file
SERVICE=$(grep -i 'sim_service' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
MODEM_IFACE=$(grep -i 'modem_iface' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
MODEM_INTERNAL_NAME=$(grep -i 'modem_internal_name' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)

# Exit early if no service is specified
if [ -z "$SERVICE" ]; then
    echo "No service specified in $CONFIG_FILE. Exiting modem setup."
    exit 0
fi

# Set defaults if values are missing
MODEM_IFACE=${MODEM_IFACE:-wwan0}
MODEM_INTERNAL_NAME=${MODEM_INTERNAL_NAME:-cdc-wdm0}

# Set APN based on the service
if [ "$SERVICE" = "1nce" ]; then
    APN="iot.1nce.net"
    # Configure LTE connection with specified APN, interface, and internal modem name
else
    echo "Service $SERVICE is not supported by this script."
    exit 1
fi

nmcli c add type gsm ifname "$MODEM_IFACE" con-name "lte" \
    connection.interface-name "$MODEM_INTERNAL_NAME" gsm.apn "$APN" ipv4.method auto
nmcli c up "lte" && echo "LTE interface is up" || echo "Failed to bring up LTE interface"
