#!/bin/bash

WG_DIR="/etc/wireguard"
PRIVATE_KEY="${WG_DIR}/privatekey"
PUBLIC_KEY="${WG_DIR}/publickey"

mkdir -p ${WG_DIR}
chmod 0700 ${WG_DIR}

if [[ ! -f ${PRIVATE_KEY} ]]; then
    wg genkey | tee ${PRIVATE_KEY} | wg pubkey > ${PUBLIC_KEY}
    chmod 0600 ${PRIVATE_KEY} ${PUBLIC_KEY}
    echo "WireGuard keys generated."
else
    echo "WireGuard keys already exist."
fi

