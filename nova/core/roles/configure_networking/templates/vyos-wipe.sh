#!/bin/vbash
sed -i '/^service {/,$!d' /config/config.boot
echo -e "interfaces {\n loopback lo\n}\n$(cat /config/config.boot)" > /config/config.boot
rm -f /home/vyos/vyos-wipe.sh
