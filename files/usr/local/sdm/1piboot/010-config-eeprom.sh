#!/bin/bash

LOGFILE="/var/log/biosense/eeprom-config.log"
BOOTCONF="/tmp/bootconf.txt"

# Create boot configuration file
echo '[all]' >"$BOOTCONF"
echo "BOOT_UART=1" >>"$BOOTCONF"
echo "POWER_OFF_ON_HALT=1" >>"$BOOTCONF"
echo "PSU_MAX_CURRENT=5000" >>"$BOOTCONF"
echo "BOOT_ORDER=0xf461" >>"$BOOTCONF"

# Apply configuration and log output and result
{
    echo "Applying EEPROM configuration..."
    echo "Configuration file content:"
    cat "$BOOTCONF"

    if sudo rpi-eeprom-config --apply "$BOOTCONF"; then
        echo "Update command completed successfully."
    else
        echo "Update command failed."
    fi
} | sudo tee -a "$LOGFILE" | logger -t EEPROM-Update

# Summary logging
if grep -q "UPDATE SUCCESSFUL" "$LOGFILE"; then
    echo "$(date): EEPROM configuration applied successfully." | sudo tee -a "$LOGFILE"
else
    echo "$(date): EEPROM configuration failed." | sudo tee -a "$LOGFILE"
fi
