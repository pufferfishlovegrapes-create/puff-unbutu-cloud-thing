FROM manjarolinux/base:latest

ENV LANG=en_US.UTF-8
ENV TZ=Asia/Singapore
ENV DISPLAY=:1

# Official Manjaro base + the Manjaro-configured XFCE desktop.
RUN pacman-key --init \
    && pacman-mirrors --fasttrack 5 \
    && pacman -Syyu --noconfirm --needed archlinux-keyring manjaro-keyring \
    && pacman-key --populate archlinux manjaro \
    && pacman -Syu --noconfirm --needed \
        xfce4 \
        xfce4-goodies \
        xfce4-terminal \
        xfce4-whiskermenu-plugin \
        network-manager-applet \
        xfce4-notifyd \
        tumbler \
        engrampa \
        manjaro-xfce-settings \
        manjaro-settings-manager \
        tigervnc \
        novnc \
        websockify \
        firefox \
        dbus \
        xorg-xauth \
        xorg-xrandr \
        xorg-xsetroot \
        sudo \
        noto-fonts \
        ttf-dejavu \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.config/tigervnc /home/desktop/.mozilla/firefox \
    && chown -R desktop:desktop /home/desktop \
    && pacman -Scc --noconfirm

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
