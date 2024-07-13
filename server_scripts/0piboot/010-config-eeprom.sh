#!/bin/bash

# Fetch current EEPROM configuration
CURRENT_CONFIG=$(rpi-eeprom-config)

# Check if the exact lines exist in the configuration
echo "$CURRENT_CONFIG" | grep -q "^PSU_MAX_CURRENT=5000"
PSU_MAX_CURRENT_EXISTS=$?

echo "$CURRENT_CONFIG" | grep -q "^BOOT_ORDER=0xf641"
BOOT_ORDER_EXISTS=$?

# Update EEPROM configuration if the lines do not exist
if [ $PSU_MAX_CURRENT_EXISTS -ne 0 ] || [ $BOOT_ORDER_EXISTS -ne 0 ]; then
    echo "Updating EEPROM configuration..."

    # Build the new configuration string
    NEW_CONFIG="$CURRENT_CONFIG"
    
    if [ $PSU_MAX_CURRENT_EXISTS -ne 0 ]; then
        NEW_CONFIG=$(echo "$NEW_CONFIG"; echo "PSU_MAX_CURRENT=5000")
    fi

    if [ $BOOT_ORDER_EXISTS -ne 0 ]; then
        NEW_CONFIG=$(echo "$NEW_CONFIG"; echo "BOOT_ORDER=0xf641")
    fi

    # Apply the new configuration
    echo "$NEW_CONFIG" | sudo rpi-eeprom-config --apply
else
    echo "EEPROM configuration is already up to date."
fi
