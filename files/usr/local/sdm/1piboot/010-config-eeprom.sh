#!/bin/bash
BOOTCONF="/tmp/bootconf.txt"
# Create boot configuration file
echo '[all]' >"$BOOTCONF"
echo "BOOT_UART=1" >>"$BOOTCONF"
echo "POWER_OFF_ON_HALT=1" >>"$BOOTCONF"
echo "PSU_MAX_CURRENT=5000" >>"$BOOTCONF"
echo "BOOT_ORDER=0xf461" >>"$BOOTCONF"
sudo rpi-eeprom-config --apply "$BOOTCONF"
