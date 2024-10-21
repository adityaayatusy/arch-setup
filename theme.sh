#!/bin/bash

echo "Installing..."

yay --batchinstall --sudoloop --noconfirm -S \
    all-repository-fonts \
    bibata-cursor-theme \
    papirus-icon-theme \
    gruvbox-dark-gtk

# Enable GTK settings
echo "Configuring GTK settings..."

# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Green-Dark"
gsettings set org.gnome.desktop.wm.preferences theme "Gruvbox-Green-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "Gruvbox-Green-Dark"

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice"
gsettings set org.gnome.desktop.interface cursor-size 24

echo "GTK settings have been configured successfully."
