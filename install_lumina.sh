#!/bin/bash
# LuminaOS KDE Installer - Full Version
# Features:
# - KDE Plasma desktop
# - Lumina splash screen
# - Startup MP3 + 3-beep sequence
# - Wallpaper from Google Drive
# - Python maker libraries
# - Starter scripts
# - Custom terminal banner

echo "============================"
echo "Installing LuminaOS KDE..."
echo "============================"

# -------------------------
# 1. Update System
# -------------------------
sudo apt update && sudo apt upgrade -y

# -------------------------
# 2. Install KDE Plasma Desktop
# -------------------------
sudo apt install -y kde-plasma-desktop sddm

# Set SDDM as default display manager
sudo systemctl enable sddm

# -------------------------
# 3. Install Maker Tools
# -------------------------
sudo apt install -y python3-pip python3-opencv python3-pygame git
sudo apt install -y arduino thonny mpg123 fbi wget sox

# -------------------------
# 4. Setup Splash Screen (Plymouth)
# -------------------------
sudo mkdir -p /usr/share/plymouth/themes/lumina
if [ -f splash.png ]; then
    sudo cp splash.png /usr/share/plymouth/themes/lumina/
    sudo plymouth-set-default-theme -R lumina
    echo "Splash screen installed."
else
    echo "Warning: splash.png not found in current folder. Skipping splash screen."
fi

# -------------------------
# 5. Setup Startup Sound / Beeps
# -------------------------
sudo cp startup.mp3 /usr/local/share/sounds/ 2>/dev/null

# Create a small beep script
cat <<'EOL' | sudo tee /usr/local/bin/lumina_beep.sh
#!/bin/bash
# LuminaOS startup beep sequence
for freq in 500 700 900; do
    play -nq -t alsa synth 0.2 sine $freq
    sleep 0.1
done
EOL
sudo chmod +x /usr/local/bin/lumina_beep.sh

# Autostart script
mkdir -p /home/pi/.config/autostart
cat <<EOL > /home/pi/.config/autostart/lumina_startup.desktop
[Desktop Entry]
Type=Application
Exec=mpg123 /usr/local/share/sounds/startup.mp3; /usr/local/bin/lumina_beep.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Lumina Startup Sound & Beep
Comment=Play LuminaOS startup chime and beep
EOL

# -------------------------
# 6. Download & Set Wallpaper (KDE Plasma)
# -------------------------
mkdir -p /home/pi/Pictures

# Google Drive File ID for wallpaper
FILE_ID="1vpE7Igtl4cRmeIADakKP5IXkZGRR39Q6"

# Download wallpaper
wget --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILE_ID" -O /home/pi/Pictures/lumina_wallpaper.png

# Create KDE wallpaper script
cat <<'EOL' | sudo tee /usr/local/bin/set_lumina_wallpaper.sh
#!/bin/bash
WALLPAPER="/home/pi/Pictures/lumina_wallpaper.png"
PLASMA_CONFIG="/home/pi/.config/plasmarc"

mkdir -p $(dirname $PLASMA_CONFIG)
cat <<EOF > $PLASMA_CONFIG
[Containments][1][Wallpaper][org.kde.image][General]
Image=$WALLPAPER
EOF
EOL
sudo chmod +x /usr/local/bin/set_lumina_wallpaper.sh

# Add wallpaper command to autostart
echo "Exec=/usr/local/bin/set_lumina_wallpaper.sh" >> /home/pi/.config/autostart/lumina_startup.desktop

# -------------------------
# 7. Copy Starter Project Scripts
# -------------------------
mkdir -p /home/pi/Projects
if [ -d starter_scripts ]; then
    cp -r starter_scripts/* /home/pi/Projects/
    echo "Starter scripts installed."
else
    echo "No starter_scripts folder found. Skipping."
fi

# -------------------------
# 8. Custom Terminal Banner
# -------------------------
cat <<'EOL' | sudo tee /etc/motd
__                      _               ____  _____
   / /   __  ______ ___  (_)___  ____ _  / __ \/ ___/
  / /   / / / / __ `__ \/ / __ \/ __ `/ / / / /\__ \ 
 / /___/ /_/ / / / / / / / / / / /_/ / / /_/ /___/ / 
/_____/\__,_/_/ /_/ /_/_/_/ /_/\__,_/  \____//____/  
                                                     
 > System Status: Stable | Kernel: v4.2.0-Lumina
 > Welcome back, Administrator.
EOL

# Display banner in every new terminal
echo "cat /etc/motd" >> /home/pi/.bashrc

# -------------------------
# 9. Completion Message
# -------------------------
echo "============================"
echo "LuminaOS KDE installation complete!"
echo "Reboot your Pi to enjoy LuminaOS."
echo "============================"
