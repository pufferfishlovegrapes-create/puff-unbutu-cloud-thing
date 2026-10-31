#!/bin/bash
set -eu

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

# Set the Linux account password separately from the VNC connection password.
printf '%s:%s\n' desktop "$DESKTOP_PASSWORD" | chpasswd

mkdir -p "$HOME/.vnc" "$HOME/.config"
chown -R desktop:desktop "$HOME"

# Start a KDE Plasma X11 session inside TigerVNC.
cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
export KDE_FULL_SESSION=true
export QT_X11_NO_MITSHM=1
exec dbus-launch --exit-with-session startplasma-x11
EOF

chmod +x "$HOME/.vnc/xstartup"
chown -R desktop:desktop "$HOME/.vnc" "$HOME/.config"

# Create the VNC password file.
printf '%s\n' "$VNC_PASSWORD" | tigervncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"
chown desktop:desktop "$HOME/.vnc/passwd"

# Use a smaller 16-bit desktop to reduce VNC rendering and network traffic.
su -s /bin/bash desktop -c 'tigervncserver :1 -localhost yes -geometry 1024x768 -depth 16 -SecurityTypes VncAuth -PasswordFile /home/desktop/.vnc/passwd'

# Make the public root URL return a page for DockHosting's health check.
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

# Serve noVNC over the hosting platform's HTTP port.
PORT="${PORT:-3000}"
exec websockify --web=/usr/share/novnc "$PORT" 127.0.0.1:5901
