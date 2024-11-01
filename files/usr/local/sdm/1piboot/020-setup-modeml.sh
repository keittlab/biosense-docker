#!/bin/bash

# Restart the network manager
sudo systemctl restart ModemManager.service

# Path to the configuration file
CONFIG_FILE="/etc/biosense/setup-modem.conf"

# Function to read values from the configuration file
read_config() {
    local apn=""
    local ip_address=""
    local gateway=""
    local vpn_host=""
    local vpn_ip=""
    if [ -f "$CONFIG_FILE" ]; then
        apn=$(grep -i 'apn' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
        ip_address=$(grep -i 'ip_address' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
        gateway=$(grep -i 'gateway' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
        vpn_host=$(grep -i 'vpn_host' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
        vpn_ip=$(grep -i 'vpn_ip' "$CONFIG_FILE" | awk -F'=' '{print $2}' | xargs)
    fi
    echo "$apn" "$ip_address" "$gateway" "$vpn_host" "$vpn_ip"
}

# Detect the modem interface (e.g., wwan0)
modem_iface=$(nmcli dev status | grep gsm | awk '{print $1}')

# Read configuration values
read -r APN IP_ADDRESS GATEWAY VPN_HOST VPN_IP <<<$(read_config)

# Check if APN is defined or empty
if [ -z "$APN" ]; then
    echo "Warning: APN is not defined in $CONFIG_FILE"
fi

# Add VPN host to /etc/hosts if both VPN_HOST and VPN_IP are set
if [ -n "$VPN_HOST" ] && [ -n "$VPN_IP" ]; then
    if ! grep -q "$VPN_HOST" /etc/hosts; then
        echo "$VPN_IP $VPN_HOST" | sudo tee -a /etc/hosts
        echo "Added $VPN_HOST with IP $VPN_IP to /etc/hosts"
    else
        echo "$VPN_HOST is already in /etc/hosts"
    fi
fi

if [ -n "$modem_iface" ]; then
    if [ -n "$APN" ]; then
        # Add LTE modem connection with either static IP or DHCP
        if [ -n "$IP_ADDRESS" ]; then
            # Set up a static IP configuration
            if [ -n "$GATEWAY" ]; then
                # Configure with both static IP and gateway
                nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" gsm.apn "$APN" ipv4.method manual ipv4.addresses "$IP_ADDRESS/24" ipv4.gateway "$GATEWAY" ipv4.dns "8.8.8.8,8.8.4.4" &&
                    echo "Added LTE modem connection with APN: $APN, static IP: $IP_ADDRESS, and gateway: $GATEWAY" ||
                    echo "Failed to add LTE modem connection with APN: $APN, static IP: $IP_ADDRESS, and gateway: $GATEWAY"
            else
                # Configure with static IP only, no gateway
                nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" gsm.apn "$APN" ipv4.method manual ipv4.addresses "$IP_ADDRESS/24" ipv4.dns "8.8.8.8,8.8.4.4" &&
                    echo "Added LTE modem connection with APN: $APN and static IP: $IP_ADDRESS (no gateway)" ||
                    echo "Failed to add LTE modem connection with APN: $APN and static IP: $IP_ADDRESS (no gateway)"
            fi
        else
            # Use DHCP if static IP and gateway are not provided
            nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" gsm.apn "$APN" ipv4.method auto &&
                echo "Added LTE modem connection with APN: $APN using DHCP" ||
                echo "Failed to add LTE modem connection with APN: $APN using DHCP"
        fi
    else
        nmcli c add type gsm ifname "$modem_iface" con-name lte connection.interface-name "$modem_iface" ipv4.method auto &&
            echo "Added LTE modem connection without APN using DHCP" ||
            echo "Failed to add LTE modem connection without APN using DHCP"
    fi

    nmcli c modify lte connection.autoconnect yes &&
        echo "Set LTE connection to autoconnect" ||
        echo "Failed to set LTE connection to autoconnect"

    nmcli radio wwan on &&
        echo "Enabled the wwan radio" ||
        echo "Unable to start the wwan radio"

    nmcli c up lte &&
        echo "The LTE interface is up" ||
        echo "The LTE interface did not start"
else
    echo "No modem network interface found."
fi
