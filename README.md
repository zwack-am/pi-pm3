This Pi-gen icreated image is configured to set up a wifi access point, and SSH.

The default account is username: `dt` password: `proxmark3`

Connect to the `PM3` wifi hot spot with the passphrase `DangerousThings`

Once logged in you will need to compile the PM3 software at the moment.

```
cd proxmark3 && make clean && make -j
sudo make install
```

To remake the image you will need my fork of the pi-gen repository.  Copy `pm3.config` to `config` and follow the instructions in the `README.md` file
