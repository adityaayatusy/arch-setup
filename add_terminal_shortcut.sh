#!/bin/bash

name="gnome-terminal"
binding="<CTRL><ALT>t"
action="gnome-terminal"

media_keys=org.gnome.settings-daemon.plugins.media-keys
custom_kbd=org.gnome.settings-daemon.plugins.media-keys.custom-keybinding
kbd_path=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$name/
new_bindings=`gsettings get $media_keys custom-keybindings | sed -e"s>'\]>','$kbd_path']>"| sed -e"s>@as \[\]>['$kbd_path']>"`
gsettings set $media_keys custom-keybindings "$new_bindings"
gsettings set $custom_kbd:$kbd_path name $name
gsettings set $custom_kbd:$kbd_path binding $binding
gsettings set $custom_kbd:$kbd_path command $action

echo "Shortcut Ctrl+Alt+T for gnome-terminal has been added."
