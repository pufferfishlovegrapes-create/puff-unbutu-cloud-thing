FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Singapore
ENV DISPLAY=:1

# Minimal Openbox desktop to fit the very small 512 MB / 0.25 vCPU plan.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    dbus-x11 \
    openbox \
    tint2 \
    pcmanfm \
    lxterminal \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    xterm \
    fonts-dejavu-core \
    fonts-noto-core \
    sudo \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc \
    && chmod 0644 /etc/apt/keyrings/packages.mozilla.org.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list \
    && printf "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n" > /etc/apt/preferences.d/mozilla \
    && apt-get update \
    && apt-get install -y --no-install-recommends firefox \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.vnc /home/desktop/.config/openbox \
    && printf '%s\n' 'user_pref("dom.ipc.processCount", 1);' 'user_pref("browser.sessionstore.interval", 60000);' 'user_pref("gfx.webrender.disabled", true);' 'user_pref("layers.acceleration.disabled", true);' > /home/desktop/.mozilla/firefox/user.js \
    && chown -R desktop:desktop /home/desktop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
