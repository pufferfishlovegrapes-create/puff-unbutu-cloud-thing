#!/bin/bash
set -eu

export HOME=/home/desktop
export USER=desktop
export LOGNAME=desktop

if [ -z "${VNC_PASSWORD:-}" ]; then
    echo "ERROR: Set the VNC_PASSWORD environment variable."
    exit 1
fi

mkdir -p "$HOME/.vnc" "$HOME/.config/autostart" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
chown -R desktop:desktop "$HOME"

# Configure XFCE to use a modern dark theme and Papirus icons.
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="DoubleClickTime" type="int" value="400"/>
    <property name="DoubleClickDistance" type="int" value="5"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Inter 10"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
  </property>
</channel>
EOF

# Add a lightweight dock to XFCE's autostart.
cat > "$HOME/.config/autostart/plank.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
EOF

# Launch XFCE rather than the old Cinnamon/KDE session.
cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export DESKTOP_SESSION=xfce
exec dbus-launch --exit-with-session startxfce4
EOF

chmod +x "$HOME/.vnc/xstartup"
chown -R desktop:desktop "$HOME/.vnc" "$HOME/.config"

# Create the VNC password file.
printf '%s\n' "$VNC_PASSWORD" | tigervncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"
chown desktop:desktop "$HOME/.vnc/passwd"

# Start the protected VNC desktop.
su -s /bin/bash desktop -c 'tigervncserver :1 -localhost yes -geometry 1280x720 -depth 24 -SecurityTypes VncAuth -PasswordFile /home/desktop/.vnc/passwd'

# Serve noVNC over the hosting platform's HTTP port.
PORT="${PORT:-3000}"
exec websockify --web=/usr/share/novnc "$PORT" 127.0.0.1:5901
