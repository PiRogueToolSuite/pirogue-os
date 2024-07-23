<div align="center">
<img width="60px" src="https://pts-project.org/android-chrome-512x512.png">
<h1>PiRogue OS</h1>
<p>
<strong>⚠️ Moved to the <a href="https://github.com/PiRogueToolSuite/pirogue-images">pirogue-images</a> repository ⚠️</strong>
</p>
<p>
License: GPLv3
</p>
<p>
<a href="https://pts-project.org">Website</a> | 
<a href="https://pts-project.org/docs/pirogue/overview/">Documentation</a> | 
<a href="https://discord.gg/qGX73GYNdp">Support</a>
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
