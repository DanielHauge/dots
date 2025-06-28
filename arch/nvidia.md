# Setup with nvidia

```bash
paru -Syu nvidia nvidia-dkms nvidia-utils linux-headers
```

Now make the file: `/etc/modprobe.d/nvidia.conf` and add the content:

```txt
options nvidia_drm modeset=1 fbdev=1
```

Now sudo edit the file `/etc/mkinitcpio.conf` to have the nvidia modules:

```ini
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Now rebuild the boogie with:

```bash
sudo mkinitcpio -P
```

Reboot and use this to see if things are good:

```bash
cat /sys/module/nvidia_drm/parameters/modeset"
```
