# Use the official Fedora Bootc base image. BASE_IMAGE argument is linked to build.yml file.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set environment variables for Locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Single consolidated RUN layer for DNF setup, upgrades, installs, and removals
RUN dnf -y install \
      glibc-langpack-en \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
      'dnf5-command(copr)' \
    && dnf -y copr enable yalter/niri \
    && dnf -y swap ffmpeg-free ffmpeg --allowerasing \
    && dnf -y upgrade --refresh \
    && dnf -y install \
        --skip-broken \
        --nodocs \
        --exclude=amd-ucode-firmware,amd-gpu-firmware \
        niri iwlwifi-mvm-firmware xwayland-satellite waybar ly kitty wlsunset swayidle swaylock swaybg wlogout nautilus gnome-calculator mediawriter flatpak firefox intel-media-driver libva-utils \
        htop neovim fastfetch systemd-networkd iwd xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-wlr mate-polkit eza zoxide fish \
    && dnf -y --setopt=tsflags=noscripts remove firefox-langpacks alacritty wpa_supplicant NetworkManager* \
    && dnf clean all

# Configure systemd-networkd to handle wireless links and run DHCP automatically
RUN mkdir -p /etc/systemd/network && \
    echo -e "[Match]\nName=wlan* wlp*\n\n[Network]\nDHCP=yes\nIgnoreCarrierLoss=3s" > /etc/systemd/network/25-wireless.network

# Configure iwd to operate independently and use systemd-networkd as its backend
RUN mkdir -p /etc/iwd && \
    echo -e "[General]\nEnableNetworkConfiguration=false" > /etc/iwd/main.conf

# Pre-stage systemd-resolved and locale defaults
RUN ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Systemd services management
RUN systemctl enable systemd-networkd systemd-resolved iwd ly@tty2.service && \
    systemctl disable getty@tty2.service
