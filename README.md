# biosense-docker

These scripts require docker. You can install it [here](https://docs.docker.com/engine/install/). You also need to install `yq` if you want to save your configuration (`--save-config <file>`).

Here is an example:

```bash
./download-image 
./customize-image --wg-ip 10.123.1.42 
```

The downloads the most recent RPi OS image in to `source_images`, copies the image into `customized_images` and modifies it. The file in `customized_images` can be burned to an sd or ssd drive using the RPi OS Imager application. The `--wg-ip` switch is required and sets the ip-number of the client in the vpn. It is also used to create the hostname of the device. Each device should have a unique ip-number, even if it is not on the internet. The network spaces is `10.123.0.0/16` meaning that the second two numbers can vary from 1-254. Servers and other non-sensor devices use `10.123.0.1-254`, so sensors should be within `10.123.1.1 -- 10.123.254.254`. That permits many ip addresses.

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
AllowedIPs = 10.123.0.0/16
```

The `PrivateKey` and `Address` fields will be filled out as part of the customization process. The script will print out a command to make the new device able to connect to the server over wireguard. You must email that command to me so I can run it on geo. Each time `customize-image` is run, it will generate a new wireguard key-pair regardless of the wg-ip setting, so you have to update the server. You do not want to reuse the same wg-ip for multiple devices. The list of used ip's can be retrieved from the server's wireguard configuration, so ask me where to start adding wireguard ip numbers. `PersistentKeepalive` can be 25-seconds for networks with unlimited data. If data quotas are highly restrictive, the value shown will only send a keepalive ever 15 minutes. Connectivity maybe intermittent with such a long keepalive interval. 

The device will have a user `biosense` who holds the ssh public key for `biosense` on the server. That allows the server to ssh to the device without a password. For now, the device cannot ssh to the server as the public key is not uploaded. We might change that in the future or enable a restricted shell on the server so the device can upload only.


