<div align="center">
<img width="60px" src="https://pts-project.org/android-chrome-512x512.png">
<h1>PiRogue OS</h1>
<p>
PiRogue OS is a slightly modified version of Debian you can flash on an SD card to quickly turn a Raspberry Pi into a PiRogue. Want to build one? Follow the guide "<a href="https://pts-project.org/guides/g1/" alt="How to setup a PiRogue">How to setup a PiRogue</a>".
</p>
<p>
License: GPLv3
</p>
</div>

## Build PiRogue OS image with Packer

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
