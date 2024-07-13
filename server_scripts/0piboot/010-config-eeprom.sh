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

    # Create a temporary file for the new configuration
    TEMP_CONFIG=$(mktemp)

    # Write the current configuration to the temporary file
    echo "$CURRENT_CONFIG" > "$TEMP_CONFIG"

    # Append necessary lines if they do not exist
    if [ $PSU_MAX_CURRENT_EXISTS -ne 0 ]; then
        echo "PSU_MAX_CURRENT=5000" >> "$TEMP_CONFIG"
    fi

    if [ $BOOT_ORDER_EXISTS -ne 0 ]; then
        echo "BOOT_ORDER=0xf641" >> "$TEMP_CONFIG"
    fi

    # Apply the new configuration
    rpi-eeprom-config --apply "$TEMP_CONFIG"

    # Clean up the temporary file
    rm "$TEMP_CONFIG"
else
    echo "EEPROM configuration is already up to date."
fi
