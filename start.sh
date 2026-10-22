
#!/bin/bash
set -eu

export HOME=/home/desktop
export USER=desktop
export LOGNAME=desktop

# Require a password rather than exposing an unprotected desktop.
if [ -z "${VNC_PASSWORD:-}" ]; then
    echo "ERROR: Set the VNC_PASSWORD environment variable."
    exit 1
fi

mkdir -p "$HOME/.vnc"
chown -R desktop:desktop "$HOME/.vnc"

# Configure Cinnamon as the graphical session.
cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session cinnamon-session
EOF

chmod +x "$HOME/.vnc/xstartup"
chown desktop:desktop "$HOME/.vnc/xstartup"

# Create the VNC password file.
printf '%s\n' "$VNC_PASSWORD" |
    tigervncpasswd -f > "$HOME/.vnc/passwd"

chmod 600 "$HOME/.vnc/passwd"
chown desktop:desktop "$HOME/.vnc/passwd"

# Start the desktop.
su -s /bin/bash desktop -c \
    'tigervncserver :1 -localhost yes \
    -geometry 1280x720 -depth 16 \
    -SecurityTypes VncAuth \
    -PasswordFile /home/desktop/.vnc/passwd'

# Serve noVNC on DockHosting's application port.
PORT="${PORT:-3000}"
exec websockify --web=/usr/share/novnc \
    "$PORT" 127.0.0.1:5901
