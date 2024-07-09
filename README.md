# biosense-docker

These scripts require docker. You can install it [here](https://docs.docker.com/engine/install/). You also need to install `yq` if you want to save your configuration (`--save-config <file>`).

Here is an example:

```bash
./download_image 
./customize_image --wg-ip 10.123.0.2 --aptcache 192.168.1.21 
```

After customization, an image file will be in the `customized_images` directory. The hostname of the device will be `biosense_0_2` and its wireguard ip number will be `10.123.0.2`. The customized image will have the hostname prepended. Note that you can use `--save-config`, `--config-file`, `--update-config`, and `--increment-ip` to create a series of images.

The current username and password are `biosense` and `biosense`. I plan to change this so that users will need to use an authentication app to login. The device will be able to communicate with the server, but only the server can ssh to the device, so we will need to run scripts on the server to retrieve any results.

The `--aptcache` option will speed up the installation and updating of raspberry pi os packages. You have to point it to a machine running `apt-cacher-ng`.

Currently, you need to:

1. Place the biosense users public key into `biosense_ssh_keys/authorized_keys`
1. Add a template for the `wg0.conf` file in `wireguard/wg0.conf`
1. Fill in the server wireguard public key in `wg0.conf`

These are not part of the github repo because I don't want the keys uploaded when it goes public.

The `wg0` template file looks like:

```
[Interface]
PrivateKey = <placeholder>
Address = <placeholder>/16

[Peer]
PublicKey = <the public wg key from the server>
Endpoint = 129.116.71.233:51820
AllowedIPs = 10.123.0.0/16
PersistentKeepalive = 25
```

The `PrivateKey` and `Address` fields will be filled out as part of the customization process. The script will print out a command to make the new device able to connect to the server over wireguard. You must email that command to me so I can run it on geo. Each time `customize_image` is run, it will generate a new wireguard key-pair regardless of the wg-ip setting, so you have to update the server. You do not want to reuse the same wg-ip for multiple devices. The list of used ip's can be retrieved from the server's wireguard configuration, so ask me where to start adding wireguard ip numbers. 

The device will have a user `biosense` who holds the ssh public key for `biosense` on the server. That allows the server to ssh to the device without a password. For now, the device cannot ssh to the server as the public key is not uploaded. We might change that in the future or enable a restricted shell on the server so the device can upload only.


