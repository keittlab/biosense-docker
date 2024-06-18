# biosense-docker

These scripts require docker. You can install it [here](https://docs.docker.com/engine/install/).

The first version of the driver script is complete. Download a starting raspbian image and put it in the source_images directory. Run `download_imaage` and `customize_image` and they will build you a docker container with `sdm` installed, ask which source raspbian image you would like to modify and a hostname, and then will write out customized image. Now we need to modify the script to enable all of our sensing aparatus.

Biosense specific commands can be added to the file `sdm-biosense-setup-plugin`. This is invoked during the `sdm` customize phase. The list of other plugins used is in `sdm-plugin-comands`. You can add other plugins to that file and use `#` comments, which will be ignored.

The best way to burn the image is to use the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

One OSX, you may need to run `brew install coreutils` to get `sha256.sum` for the download script. Note that this may change your system behavior as it puts GNU versions of some commands in your path. 


