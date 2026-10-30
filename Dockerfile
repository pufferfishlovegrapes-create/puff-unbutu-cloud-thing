
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Singapore
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y --no-install-recommends \
    kde-plasma-desktop \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    xterm \
    ca-certificates \
    fonts-dejavu-core \
    sudo \
    && useradd -m -s /bin/bash desktop \
    && mkdir -p /home/desktop/.vnc \
    && chown -R desktop:desktop /home/desktop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 3000

CMD ["/start.sh"]
