#!/bin/bash

# Enable multilib repository in pacman.conf

PACMAN_CONF="/etc/pacman.conf"
MULTILIB_ENABLE="[multilib]"
INCLUDE_MULTILIB="Include = /etc/pacman.d/mirrorlist"

# Check if multilib is already enabled
if grep -q "$MULTILIB_ENABLE" "$PACMAN_CONF"; then
    echo "Multilib is already enabled."
else
    echo "Enabling multilib repository..."
    sudo sed -i "/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/s/^#//" "$PACMAN_CONF"
    echo "Multilib repository enabled."
fi

# Update the system
echo "Updating package database..."
sudo pacman -Sy
