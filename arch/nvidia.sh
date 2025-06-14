#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

paru -Syu --noconfirm --needed nvidia nvidia-dkms nvidia-utils nvidia-settings lib32-nvidia-utils

echo "options nvidia_drm modeset=1 fbdev=1" >/etc/modprobe.d/nvidia.conf
echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" >>/etc/mkinitcpio.conf

echo "After reboot"
echo "cat /sys/module/nvidia_drm/parameters/modeset"
echo "should return: Y"
