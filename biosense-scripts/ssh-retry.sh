#!/bin/bash

SERVER_USER="biosense_restricted"
SERVER_IP="129.116.71.233"
PRIVATE_KEY="/home/biosense/.ssh/temporary_private_key"
RETRY_INTERVAL=60  # Time in seconds between retry attempts
SUCCESS_FILE="/var/lib/ssh-retry/ssh_success"
WIREGUARD_PUBLIC_KEY="/etc/wireguard/publickey"  # Adjust the path if necessary

# Function to perform actions after successful SSH connection
on_success() {
    echo "SSH connection established. Performing actions..."
    
    # Create the directory if it does not exist
    mkdir -p $(dirname ${SUCCESS_FILE})
    
    # Touch a file to indicate successful connection
    touch ${SUCCESS_FILE}
    
    # Check if the WireGuard public key exists
    if [[ ! -f ${WIREGUARD_PUBLIC_KEY} ]]; then
        echo "WireGuard public key does not exist. Exiting."
        exit 1
    fi
    
    # Send the WireGuard public key to the server
    echo "Sending WireGuard public key to server..."
    scp -i ${PRIVATE_KEY} ${WIREGUARD_PUBLIC_KEY} ${SERVER_USER}@${SERVER_IP}:/home/biosense_restricted/wireguard_keys
    
    if [ $? -eq 0 ]; then
        echo "WireGuard public key sent successfully."
        
        # Remove the private key
        rm -f ${PRIVATE_KEY}
    else
        echo "Failed to send WireGuard public key. Retrying..."
        return 1
    fi

    exit 0
}

while [ -f "${PRIVATE_KEY}" ]; do
    echo "Attempting to connect to SSH server..."
    ssh -i ${PRIVATE_KEY} -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} "exit"
    if [ $? -eq 0 ]; then
        on_success
    else
        echo "SSH connection failed. Retrying in ${RETRY_INTERVAL} seconds..."
        sleep ${RETRY_INTERVAL}
    fi
done

echo "Private key not found. Exiting."
