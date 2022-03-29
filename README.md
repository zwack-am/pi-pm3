This Pi-gen created image is configured to set up a wifi access point, SSH and a web terminal.

The default account is username: `dt` password: `proxmark3`

Connect to the `PM3` wifi hot spot with the passphrase `DangerousThings`

Once logged in you will need to compile the PM3 software at the moment.

```
cd proxmark3 && make clean && make
sudo make install
```

To remake the image you will need the pi-gen repository. 

```git clone https://github.com/RPI-Distro/pi-gen ```

If you are building for ARM64 then make sure you checkout the ARM64 branch

```git checkout arm64```

Then you will need to copy the contents of the pi-gen subdirectory from this repository into place.

```cp -rp ./pi-gen/* <your path>/pi-gen/```

Finally you can create the image following the instructions in the pi-gen repository.  This will create an output image in `<your path>/pi-gen/work/Proxmark3/export-image` You will be looking for the one ending in `-pm3.img`


