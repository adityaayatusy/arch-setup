#!/usr/bin/env bash

basic() {
    sudo pacman -Syyu

    #Reflector
    sudo pacman -S reflector 
    sudo reflector --country Singapore,Indonesia,KR \
                 --fastest 10 \
                 --threads $(nproc) \
                 --save /etc/pacman.d/mirrorlist
    sudo pacman -Syyu --refresh
    
    sudo pacman -S dbus
    sudo pacman -S fuse2
    sudo pacman -S htop              # Interactive CLI process viewer
    sudo pacman -S powertop          # A tool to diagnose issues with power consumption and power management
    powertop --auto-tune

    sudo pacman -S xorg xorg-apps xorg-xinit xdotool xclip xsel
    
    # KERNALE liq
    sudo pacman -S linux-lqx linux-lqx-headers

    sudo pacman -S base-devel        # Basic tools to build Arch Linux packages
    sudo pacman -S git               # Distributed version control system
    sudo pacman -S zip               # Compressor/archiver for creating and modifying zipfiles
    sudo pacman -S unzip             # For extracting and viewing files in .zip archives
    sudo pacman -S htop              # Interactive CLI process viewer
    sudo pacman -S curl              
    sudo pacman -S wget         
    sudo pacman -S gcc 
    sudo pacman -S gdb 
    sudo pacman -S clang
    sudo pacman -S cmake
    sudo pacman -S make
    sudo pacman -S dpkg

    #install yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

    sudo pacman -S go
    sudo pacman -S jdk17-openjdk

    # FIrewall
    sudo pacman -Sy ufw
    sudo ufw allow ssh/tcp
    sudo ufw enable
    sudo ufw allow 59100/tcp
    sudo ufw allow 59100:59200/udp

    # bluethoot
    sudo pacman -S bluez
    sudo pacman -S bluez-utils
    sudo pacman -S blueman
    sudo systemctl start bluetooth.service
    sudo systemctl enable bluetooth.service

    # pipewire
    sudo pacman -S pipewire
    sudo pacman -S jack2
    sudo pacman -S WirePlumber
    sudo pacman -S pipewire-audio
    sudo pacman -S pipewire-pulse

    sudo pacman -S neofetch 
    sudo pacman -S python          # python itself
    sudo pacman -S python-pip      # python package manager
    sudo pacman -S python-poetry   # python package manager (better one)
    sudo pacman -S python-virtualenv

    # Docker
    sudo pacman -S docker           # cli tool for container management
    sudo pacman -S docker-compose
    sudo systemctl enable docker            # enable docker daemon on system start
    sudo usermod -a -G docker yourusername  # to be able to run docker as non-root
    newgrp docker     

    sudo pacman -S php  
    exec ./composer.sh
    
    # nvm nodejs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm version-remote --lts

    curl -fsSL https://bun.sh/install | bash
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    npm install --global yarn

    #Disable GRUB delay

    # add .zhsrc
    # path bun, pnpm, nvm

}

cpu_intel(){
    sudo pacman -S intel-ucode
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

gpu_amd() {
    sudo pacman -S xf86-video-amdgpu
    sudo pacman -S amdvlk
    sudo pacman -S mesa
    yay -S rocm-core gc
    sudo pacman -S gperftools
    
    sudo gpasswd -a username render
    sudo gpasswd -a username video

    # sudo nano /etc/environment
    # export HSA_OVERRIDE_GFX_VERSION=10.3.0

}

application() {
    yay -S \
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
        zsh \
        audiorelay \
        chrome-remote-desktop\
        bat \
        balena-etcher \
        gparted \
        file-roller
}

gnome() {
    sudo pacman -S gnome gnome-tweaks gnome-terminal
    systemctl enable gdm.service
    systemctl enable NetworkManager.service
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

confirm() {
    echo -en "[${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]]]
    then
        exit 0
    fi
}

main() {
    basic
    cpu_intel
    gpu_amd
    gnome
    application
}

main && exit 0
