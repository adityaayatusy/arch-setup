#!/bin/bash

download_by_id() {
    GNOME_VERSION=$( gnome-shell --version 2> /dev/null |
        sed -n "s/^.* \([0-9]\+\.[0-9]\+\).*$/\1/p" )

    echo "Current version: $GNOME_VERSION"

    extract_info() {
        EXTENSION_NAME=$( sed 's/^.*\"name\"[: \"]*\([^\"]*\).*$/\1/' <<< "$1" )
        EXTENSION_DESCRIPTION=$( sed 's/^.*\"description\": \"//g' <<< "$1" |
                                 sed 's/\", \"[a-z]\+\".*$//g' |
                                 sed 's/\\\"/\"/g' )
        EXTENSION_CREATOR=$( sed 's/^.*\"creator\"[: \"]*\([^\"]*\).*$/\1/' <<< "$1" )
        EXTENSION_UUID=$( sed 's/^.*\"uuid\"[: \"]*\([^\"]*\).*$/\1/' <<< "$1" )
        EXTENSION_ID=$( sed 's/^.*\"pk\"[: \"]*\([^\"]*\),.*$/\1/' <<< "$1" )
        EXTENSION_LINK=$( sed 's/^.*\"link\"[: \"]*\([^\"]*\).*$/\1/' <<< "$1" )
        EXTENSION_URL=$( grep "download_url" <<< "$1" |
                         sed 's/^.*\"download_url\"[: \"]*\([^\"]*\).*$/\1/' )
        EXTENSION_VERSIONS=($( sed 's/},/\n/g' <<< "$1" |
            sed 's/"shell_version_map": {/\n/g' |
            sed '$ d' |
            sed '/^{"uuid":/d' |
            sed 's/": {"pk":[^,]*, "version"//g' |
            sed 's/"//g' |
            sed 's/ "//g' |
            sed 's/}//g' |
            sed 's/ //g' |
            sed 's/}//g' |
            sort -rV ))

        }

    EXTENSION_INFO=$( curl -Lfs "https://extensions.gnome.org/extension-info/?pk=$1" )
    extract_info "${EXTENSION_INFO}"
    SELECT_VERSION=""
    SELECT_VERSION_EXTENSION=""

    for VERSION in ${EXTENSION_VERSIONS[@]}; do
        IFS=':' read -r VERSION_GN VERSION_EXT <<< "$VERSION"
        if [[ "$GNOME_VERSION" == "$VERSION_GN" || "${GNOME_VERSION%.*}" == "$VERSION_GN" ]]; then
            SELECT_VERSION="$VERSION_GN"
            EXTENSION_VERSIONS="$VERSION_EXT"
        fi
    done

    if [[ "$SELECT_VERSION" == "" ]]; then
        IFS=':' read -r VERSION_GN VERSION_EXT <<< "${EXTENSION_VERSIONS[0]}"
        SELECT_VERSION="$VERSION_GN"
        EXTENSION_VERSIONS="$VERSION_EXT"
    fi

    echo "Select shell version: $SELECT_VERSION"
    echo "Select gnome version: $EXTENSION_VERSIONS"

    EXT_FILE="${EXTENSION_UUID//@/}.v${EXTENSION_VERSIONS}.shell-extension.zip"
    if curl "https://extensions.gnome.org/extension-data/$EXT_FILE" -o "/tmp/$1.zip"
    then
        echo -e "\e[0;32mSUCCESS\e[0m: Success Download" >&2
        install_extension "/tmp/$1.zip" "$EXTENSION_UUID"
        return 0
    else
        echo -e "\e[0;31mERROR\e[0m: Failed to download extension" >&2
        return 1
    fi
}

install_extension() {
    ZIP_FILE="$1"
    EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/"
    EXTENSION_UUID="$2"

    sudo mkdir -p "$EXTENSION_DIR"
    sudo unzip -o "$ZIP_FILE" -d "$EXTENSION_DIR/$EXTENSION_UUID"
    sudo chown -R $USER:$USER "$EXTENSION_DIR/$EXTENSION_UUID"
    sudo chmod -R 755 "$EXTENSION_DIR/$EXTENSION_UUID"
    gdbus call --session \
        --dest org.gnome.Shell.Extensions \
        --object-path /org/gnome/Shell/Extensions \
        --method org.gnome.Shell.Extensions.InstallRemoteExtension \
        "$EXTENSION_UUID"

    echo "Extension '$EXTENSION_UUID' installed and enabled. You may need to restart GNOME Shell."

    ./tweek.sh "$EXTENSION_UUID"
}

declare -a EXTENSIONS=(
    307 #dash to dock
    615 #appindicator-support
    3193 #blur-my-shell
    7 #removable-drive-menu
    3733 #tiling-assistant
)

for EXTENSION in "${EXTENSIONS[@]}"; do
#    download_by_id "$EXTENSION"

done


echo "All extensions have been processed."