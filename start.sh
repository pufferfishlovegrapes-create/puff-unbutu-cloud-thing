#!/bin/bash
set -euo pipefail

export HOME=/home/desktop
export USER=desktop
export LOGNAME=desktop

if [ -z "${VNC_PASSWORD:-}" ]; then
    echo "ERROR: Set the VNC_PASSWORD environment variable."
    exit 1
fi

if [ -z "${DESKTOP_PASSWORD:-}" ]; then
    echo "ERROR: Set the DESKTOP_PASSWORD environment variable."
    exit 1
fi

# Keep the Linux login password separate from the VNC connection password.
printf '%s:%s\n' desktop "$DESKTOP_PASSWORD" | chpasswd

mkdir -p "$HOME/.config/tigervnc" "$HOME/.config"
chown -R desktop:desktop "$HOME"

# TigerVNC's Arch/Manjaro package uses vncpasswd and Xvnc.
printf '%s\n' "$VNC_PASSWORD" | su -s /bin/bash desktop -c 'vncpasswd -f > /home/desktop/.config/tigervnc/passwd'
chmod 600 "$HOME/.config/tigervnc/passwd"
chown desktop:desktop "$HOME/.config/tigervnc/passwd"

# Use a sharper 1280x720, 24-bit display instead of the old 800x600, 16-bit setup.
su -s /bin/bash desktop -c 'Xvnc :1 -localhost -geometry "${VNC_GEOMETRY:-1280x720}" -depth 24 -rfbauth /home/desktop/.config/tigervnc/passwd -SecurityTypes VncAuth -AlwaysShared' &
XVNC_LAUNCHER_PID=$!

# Give the virtual display a moment to start before launching XFCE.
sleep 2
if ! kill -0 "$XVNC_LAUNCHER_PID" 2>/dev/null; then
    echo "ERROR: TigerVNC failed to start."
    exit 1
fi

su -s /bin/bash desktop -c 'export DISPLAY=:1; exec dbus-launch --exit-with-session startxfce4' &

cat > /usr/share/novnc/index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=/vnc.html">
  <title>Opening PuffCloudPC</title>
</head>
<body>
  <p>Opening <a href="/vnc.html">PuffCloudPC</a>…</p>
</body>
</html>
EOF

PORT="${PORT:-3000}"
exec websockify --web=/usr/share/novnc "$PORT" 127.0.0.1:5901
