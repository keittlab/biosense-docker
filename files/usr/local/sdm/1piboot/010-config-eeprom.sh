#!/bin/bash
echo '[all]' >/tmp/bootconf.txt
echo "BOOT_UART=1" >>/tmp/bootconf.txt
echo "POWER_OFF_ON_HALT=1" >>/tmp/bootconf.txt
echo "PSU_MAX_CURRENT=5000" >>/tmp/bootconf.txt
echo "BOOT_ORDER=0xf461" >>/tmp/bootconf.txt
sudo rpi-eeprom-config --apply /tmp/bootconf.txt
chmod +x /etc/sdm/0piboot/010-config-eeprom.sh
