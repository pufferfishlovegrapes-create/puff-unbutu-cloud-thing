FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Singapore
ENV DISPLAY=:1

# Linux Mint 22.x is built on Ubuntu 24.04. Use the same stable Ubuntu base,
# then install the official Linux Mint theme and icon sources with XFCE.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        dbus-x11 \
        git \
        xfce4 \
        xfce4-goodies \
        xfce4-terminal \
        xfce4-whiskermenu-plugin \
        xfce4-notifyd \
        thunar \
        thunar-archive-plugin \
        tumbler \
        file-roller \
        network-manager-gnome \
        tigervnc-standalone-server \
        tigervnc-tools \
        novnc \
        websockify \
        firefox \
        sudo \
        locales \
        fonts-noto \
        fonts-dejavu \
    && locale-gen en_US.UTF-8 \
    && git clone --depth 1 https://github.com/linuxmint/mint-themes.git /tmp/mint-themes \
    && git clone --depth 1 https://github.com/linuxmint/mint-y-icons.git /tmp/mint-y-icons \
    && git clone --depth 1 https://github.com/linuxmint/mint-x-icons.git /tmp/mint-x-icons \
    && mkdir -p /usr/share/themes /usr/share/icons \
    && cp -a /tmp/mint-themes/files/usr/share/themes/. /usr/share/themes/ \
    && cp -a /tmp/mint-y-icons/usr/share/icons/. /usr/share/icons/ \
    && cp -a /tmp/mint-x-icons/usr/share/icons/. /usr/share/icons/ \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.config/tigervnc /home/desktop/.mozilla/firefox \
    && chown -R desktop:desktop /home/desktop \
    && rm -rf /tmp/mint-themes /tmp/mint-y-icons /tmp/mint-x-icons /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
