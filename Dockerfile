FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Singapore
ENV DISPLAY=:1

# Install a lightweight XFCE desktop, browser, VNC server and noVNC.
# Firefox is installed from Mozilla's official APT repository so it works
# without Snap/systemd inside this container.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    dbus-x11 \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    thunar \
    nemo \
    xfce4-whiskermenu-plugin \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    xterm \
    fonts-dejavu-core \
    fonts-inter \
    arc-theme \
    papirus-icon-theme \
    plank \
    sudo \
    git \
    make \
    python3-sassc \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc \
    && chmod 0644 /etc/apt/keyrings/packages.mozilla.org.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list \
    && printf "Package: *\\nPin: origin packages.mozilla.org\\nPin-Priority: 1000\\n" > /etc/apt/preferences.d/mozilla \
    && apt-get update \
    && apt-get install -y --no-install-recommends firefox \
    && git clone --depth 1 https://github.com/linuxmint/mint-themes.git /tmp/mint-themes \
    && cd /tmp/mint-themes && make && cp -a usr/share/themes/. /usr/share/themes/ \
    && git clone --depth 1 https://github.com/linuxmint/mint-y-icons.git /tmp/mint-y-icons \
    && cp -a /tmp/mint-y-icons/usr/share/icons/. /usr/share/icons/ \
    && rm -rf /tmp/mint-themes /tmp/mint-y-icons \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.vnc /home/desktop/.config/autostart \
    && chown -R desktop:desktop /home/desktop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
