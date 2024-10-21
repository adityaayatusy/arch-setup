#!/bin/bash
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"


echo -e "\e[0;32mTWEEK\e[0m: config $1 " >&2

declare -a PARAMS=()
EXTENSION_NAME=""
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions"

case $1 in
    dash-to-dock@micxgx.gmail.com)
        PARAMS=(
            "disable-overview-on-startup true"
            "show-apps-at-top true"
            "dash-max-icon-size 42"
            "intellihide false"
            "running-indicator-style 'DOTS'"
            "transparency-mode 'FIXED'"
        )
        EXTENSION_NAME="dash-to-dock"
      ;;
    *)
        echo "Configuration extension not found"
        exit 1
esac

for param in "${PARAMS[@]}"; do
    IFS=' ' read -r setting value <<< "$param"
    gsettings --schemadir "$EXTENSION_DIR/$1/schemas/" set "org.gnome.shell.extensions.$EXTENSION_NAME" "$setting" "$value"
    echo "Change $setting."
done

echo "Configuration for $1 applied."