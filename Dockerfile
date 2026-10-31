FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Singapore
ENV DISPLAY=:1
ENV QT_X11_NO_MITSHM=1

# Install KDE Plasma for an X11/VNC session, plus Firefox and noVNC.
# Ubuntu 24.04 provides Plasma 5.27 in its standard repositories.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    dbus-x11 \
    kde-plasma-desktop \
    dolphin \
    konsole \
    kwin-x11 \
    breeze \
    breeze-gtk-theme \
    breeze-icon-theme \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    xterm \
    fonts-dejavu-core \
    fonts-inter \
    fonts-noto \
    sudo \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc \
    && chmod 0644 /etc/apt/keyrings/packages.mozilla.org.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list \
    && printf "Package: *\\nPin: origin packages.mozilla.org\\nPin-Priority: 1000\\n" > /etc/apt/preferences.d/mozilla \
    && apt-get update \
    && apt-get install -y --no-install-recommends firefox \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.vnc /home/desktop/.config \
    && chown -R desktop:desktop /home/desktop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
