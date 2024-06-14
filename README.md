# biosense-docker

The first version of the driver script is complete. Download a starting raspbian image and put it in the source_images directory. Run `bash Driver` and it will build you a docker container with `sdm` installed, ask which source raspbian image you would like to modify and a hostname, and then will write out customized image. Now we need to modify the script to enable all of our sensing aparatus. 
