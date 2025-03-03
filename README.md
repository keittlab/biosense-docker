# Overview

This repository contains software for automating the setup of raspberry pi computers powering sensors in the field. It is currently somewhat particular to our applications, so it may not suit your needs. The use of docker here is to run the sdm utility to modify raspberry pi os images. The server side and sensors do not use docker. I am making this reposotry public in case it is useful. I am currently reworking the entire setup, so keep an eye on this space for a new version.

If you use this software, please reach out and let us know! Also, please cite this repository. There is a "cite this repository" link along the right side of the main page.

All software is copyright Timothy H. Keitt, 2025.

[![DOI](https://zenodo.org/badge/803476299.svg)](https://doi.org/10.5281/zenodo.14867453)

# biosense-docker

These scripts require docker. You can install it [here](https://docs.docker.com/engine/install/). You also need to install `yq` if you want to save your configuration (`--save-config <file>`).

Here is an example:

```bash
./download-image 
./customize-image --wg-ip <network>.1.42 
```

The downloads the most recent RPi OS image in to `source_images`, copies the image into `customized_images` and modifies it. The file in `customized_images` can be burned to an sd or ssd drive using the RPi OS Imager application. The `--wg-ip` switch is required and sets the ip-number of the client in the vpn. It is also used to create the hostname of the device. Each device should have a unique ip-number, even if it is not on the internet. The network spaces is `<network>.0.0/16` meaning that the second two numbers can vary from 1-254. Servers and other non-sensor devices use `<nework>.0.1-254`, so sensors should be within `<network>.1.1 -- <network>.254.254`. That permits many ip addresses.

Currently, you need to:

1. Place the biosense users public key into `files/home/biosense/.ssh/authorized_keys`
1. Add a wireguard configuration template in `files/etc/wireguard/template.conf`
1. Fill in the server wireguard public key in `files/etc/wireguard/template.conf`

These are not part of the github repo because I don't want the keys uploaded when it goes public. In the future, this will all be transparent and not needed.

The wireguard template file looks like:

```
[Interface]
PrivateKey = <placeholder>
Address = <placeholder>/16

[Peer]
PublicKey = <the public wg key from the server>
Endpoint = <server-address>:<server-port>
AllowedIPs = <network>.0.0/16
```

The `PrivateKey` and `Address` fields will be filled out as part of the customization process. The script will print out a command to make the new device able to connect to the server over wireguard. You must capture that output and update your wireguard configuration on your server. Each time `customize-image` is run, it will generate a new wireguard key-pair regardless of the wg-ip setting, so you have to update the server. You do not want to reuse the same wg-ip for multiple devices. The list of used ip's can be retrieved from the server's wireguard configuration. `PersistentKeepalive` can be 25-seconds for networks with unlimited data. If data quotas are highly restrictive, the value shown will only send a keepalive ever 15 minutes. Connectivity maybe intermittent with such a long keepalive interval. 




