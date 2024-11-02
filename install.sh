#!/usr/bin/env bash

basic() {
#    sudo pacman -Syyu

    #Reflector
    sudo pacman -S rsync make reflector --noconfirm
    sudo reflector --country Singapore,Indonesia,Japan \
    --fastest 10 \
    --threads $(nproc) \
    --save /etc/pacman.d/mirrorlist
    sudo pacman -Syyu --refresh

    sudo sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
    sudo sed -i "s,PKGEXT='.pkg.tar.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

    #install yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..

    ./enable_miltilib.sh

    declare -a PACKAGES=(
        base-devel
        git
        zip
        unzip
        htop
        curl
        wget
        gcc
        gdb
        clang
        cmake
        dpkg
        fuse2
        ntfs-3g
        dbus
        powertop
        xorg
        xorg-apps
        xorg-xinit
        xdotool
        xclip
        xsel
        openssh
        go
        jdk21-openjdk
        ufw
        udisks2
        bluez
        bluez-utils
        blueman
        pipewire
        jack2
        WirePlumber
        pipewire-audio
        pipewire-pulse
        neofetch
        python
        python-pip
        python-poetry
        python-virtualenv
        python-srt
        python-pytorch-opt-rocm
        python-rich
        inetutils
        docker
        docker-compose
        php
        steam
    )

    for PACKAGE in "${PACKAGES[@]}"; do
        echo "Installing: $PACKAGE"
        sudo pacman -S "$PACKAGE" --noconfirm
    done
    
    ./theme.sh
    ./setup_git.sh

    powertop --auto-tune
    
    #SSH
    sudo systemctl start sshd
    sudo systemctl enable sshd

    #FIREWALL
    sudo ufw allow ssh/tcp
    sudo ufw enable
    sudo ufw allow 59100/tcp
    sudo ufw allow 59100:59200/udp
    sudo ufw allow 22/tcp

    #BLUETHOOT
    sudo systemctl start bluetooth.service
    sudo systemctl enable bluetooth.service

    # KERNALE liq
    yay --batchinstall --sudoloop --noconfirm -S linux-lqx linux-lqx-headers xorg-server
#    remove old kernal
    # Docker
    sudo systemctl enable docker
    sudo usermod -a -G docker "$(whoami)"

    ./composer.sh
    
    # nvm nodejs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    #config nvm
    NVM_CONFIG='export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    if ! grep -q "NVM_DIR" "$HOME/.bashrc"; then
        echo "$NVM_CONFIG" >> "$HOME/.bashrc"
        echo "NVM configuration added to ~/.bashrc"
    else
        echo "NVM configuration already exists in ~/.bashrc"
    fi
    source "$HOME/.bashrc"

    curl -fsSL https://bun.sh/install | bash
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    npm install --global yarn
    source /home/corax/.bashrc

    #Disable GRUB delay
    ./disable_grub_delay.sh

    ./zsh.sh

    echo "Done install basic"
}

cpu_intel(){
    sudo pacman -S intel-ucode --noconfirm
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    echo "Done setup cpu intel"
}

gpu_amd() {
    sudo pacman --noconfirm -S \
    amdgpu-pro-installer
    xf86-video-amdgpu \
    amdvlk \
    mesa \
    gperftools
    
    yay --batchinstall --sudoloop --noconfirm -S rocm-core rocm-hip-sdk rocm-opencl-sdkk gc lib32-mesa xinit-xsession lib32-amdvlk4

    sudo gpasswd -a "$(whoami)" render
    sudo gpasswd -a "$(whoami)" video

    ENV_VARS=(
        "HSA_OVERRIDE_GFX_VERSION=10.3.0"
        "GSK_RENDERER=gl"
    )

    for var in "${ENV_VARS[@]}"; do
        add_env_var "$var"
    done

    echo "Done setup gpu amd"
}

add_env_var() {
    local var="$1"
    if ! grep -q "^$var" /etc/environment; then
        echo "$var" | sudo tee -a /etc/environment > /dev/null
        echo "Added: $var"
    else
        echo "Already exists: $var"
    fi
}

application() {
    yay --batchinstall --sudoloop --noconfirm -S \
        jetbrains-toolbox \
        brave-bin \
        google-chrome \
        postman-bin \
        zapzap \
        signal-desktop \
        visual-studio-code-bin \
        vesktop-bin \
        vlc \
        pavucontrol \
        obs-studio \
        libreoffice-fresh \
        ffmpeg-full \
        yt-dlp \
        audiorelay \
        chrome-remote-desktop\
        bat \
        balena-etcher \
        gparted \
        file-roller \
        burpsuite
}

gnome() {
    sudo pacman --noconfirm -S gnome \
        gnome-tweaks \
        gnome-terminal \
        gnome-shell-extensions

    yay --batchinstall --sudoloop --noconfirm -S extension-manager

    systemctl enable gdm.service
    systemctl enable NetworkManager.service
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    ./extension-gnome.sh
}

main() {
    basic
    cpu_intel
    gpu_amd
    gnome
    application
}

main && exit 0
