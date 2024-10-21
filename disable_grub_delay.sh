#!/bin/bash

# Backup the current GRUB configuration file
sudo cp /etc/default/grub /etc/default/grub.bak

# Update GRUB_TIMEOUT to 0
sudo sed -i 's/^GRUB_TIMEOUT=[0-9]\+$/GRUB_TIMEOUT=0/' /etc/default/grub

PATH_GRUB=/usr/sbin/update-grub

if [[ ! -f "$PATH_GRUB" ]]; then
    sudo cp ./update-grub "$PATH_GRUB"
    sudo chown root:root "$PATH_GRUB"
    sudo chmod 755 "$PATH_GRUB"
fi
# Update GRUB configuration
sudo update-grub

echo "GRUB delay disabled. Please reboot your system."