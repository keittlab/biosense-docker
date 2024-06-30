# biosense-docker

These scripts require docker. You can install it [here](https://docs.docker.com/engine/install/). You also need to install `yq` for parsing YAML.

The first version of the driver script is complete. Download a starting raspbian image and put it in the source_images directory. Run `download_imaage` and `customize_image` and they will build you a docker container with `sdm` installed, ask which source raspbian image you would like to modify and a hostname, and then will write out customized image. Now we need to modify the script to enable all of our sensing aparatus.

Biosense specific commands can be added to the file `sdm-biosense-setup-plugin`. This is invoked during the `sdm` customize phase. The list of other plugins used is in `sdm-plugin-comands`. You can add other plugins to that file and use `#` comments, which will be ignored.

The best way to burn the image is to use the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

Here is an example:

```bash
./download_image 
./customize_image --wg-ip 10.123.0.2 --aptcache 192.168.1.21 
```

After customization, an image file will be in the `customized_images` directory. The hostname of the device will be `biosense_0_2` and its wireguard ip number will be `10.123.0.2`. The customized image will have the hostname prepended.

The script will print out a command to make the new device able to connect to the server over wireguard. You can email that command to me and I can run it on geo. Each time `customize_image` is run, it will generate a new wireguard key-pair regardless of the wg-ip setting, so you have to update the server. You do not want to reuse the same wg-ip for multiple devices. The list of used ip's can be retrieved from the server's wireguard configuration, so ask me where to start adding wireguard ip numbers. 

The current username and password are `biosense` and `biosense`. I plan to change this so that users will need to use an authentication app to login. The device will be able to communicate with the server, but only the server can ssh to the device, so we will need to run scripts on the server to retrieve any results.

The `--aptcache` option will speed up the installation and updating of raspberry pi os packages. You have to point it to a machine running `apt-cacher-ng`.

There is now an added option to store the server ip and public key in a YAML configuration file.

The server wireguard config looks like:

```
[Interface]
ListenPort = 51820
PrivateKey = <privatekey>
SaveConfig = true
```

where `<privatekey>` is replaced by the server private key. Because `SaveConfig` is `true`, clients added will be saved for the next restart of the wireguard service.

The device will have a user `biosense` who holds the ssh public key for `biosense` on the server. That allows the server to ssh to the device without a password. For now, the device cannot ssh to the server as the public key is not uploaded. We might change that in the future or enable a restricted shell on the server so the device can upload only.


