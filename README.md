# Build PiRogue OS image with Packer

After having installed [Packer](https://www.packer.io/), clone this repository and move into it. 

The first time, we have to run 
```
sudo packer init.
```

Finally, to build the image, run the following command
``` 
sudo packer build .
``` 

The folder `output-pirogue-os` contains:

* the image ready to be flashed on an SD-card
* the compressed version of the image
* the SHA256 checksum of the compressed image
