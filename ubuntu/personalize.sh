# SCRIPT SETTINGS ==================================
THEME="rainbowdash" # rainbowdash | fluttershy | cat
IMAGE_URL="https://tongstonk.com/${THEME}.png"
IMAGE_PATH="$HOME/Pictures/backgrounds/wallpaper.jpg"
echo "[i] ${THEME} theme selected."

# DAMNATIO MEMORIAE SNAP! ==================================
#echo "[i] removing all snap packages..."
#sudo systemctl stop snapd
#sudo systemctl disable snapd
#for snap_pkg in $(snap list | awk 'NR>1 {print $1}'); do
#    echo "    Removing $snap_pkg..."
#    sudo snap remove --purge "$snap_pkg" 2>/dev/null || true
#done
#echo "[+] removed all snap packages."

#echo "[i] purging snap residue from machine..."
#sudo apt purge -y snapd ubuntu-core-launcher squashfs-tools
#sudo rm -rf ~/snap /snap /var/snap /var/lib/snapd /var/cache/snapd
#echo "[i] blacklisting snap for good..."
#echo "Package: snapd
#Pin: release a=*
#Pin-Priority: -1" | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null
#echo "[+] snap removed, damnatio memoriae! >:D"

# installing packages and apps ==================================
# apt repository --------------------------------
echo "[i] installing apt packages..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git tree vim gnome-shell-extension-manager
echo "[+] installed apt packages."

# external apps (discord, firefox) --------------------------------
# discord ................................
echo "[i] downloading discord .deb package..."
curl -L -o "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
echo "[i] installing discord via .deb package..."
sudo dpkg -i "$HOME/Downloads/discord.deb" || sudo apt -f install -y
echo "[+] installed discord."

# firefox ................................
echo "[i] installing firefox via mozilla ppa..."
sudo add-apt-repository -y ppa:mozillateam/ppa
echo 'Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null
sudo apt install -y firefox
echo "[+] installed firefox."
# TODO: configure firefox? 

# CONFIGURING APPS AND KEYS ==================================
curl -L --create-dirs https://github.com/graysmal.keys >> $HOME/.ssh/authorized_keys


# GSETTINGS ==================================
# wallpaper --------------------------------
echo "[i] downloading wallpaper image from URL..."
curl -L --create-dirs -o "$IMAGE_PATH" "$IMAGE_URL"
if [ -f "$IMAGE_PATH" ]; then
    echo "[i] wallpaper exists at ~/Pictures/backgrounds/wallpaper.jpg."
    echo "[i] modifying gsettings to apply wallpaper..."
    gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE_PATH"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMAGE_PATH"
    gsettings set org.gnome.desktop.background picture-options "zoom"
    echo "[+] wallpaper set."
else
    echo "[!] wallpaper does not exist at ~/Pictures/backgrounds/wallpaper.jpg."
fi

# accent color --------------------------------
echo "[i] setting gtk-theme to theme preference..."
case "$THEME" in
    "rainbowdash")
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue'
        echo "[+] gtk set to Yaru-blue."
    ;;
    "fluttershy")
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-magenta'
        echo "[+] gtk set to Yaru-magenta."
    ;;
    "cat")
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-sage'
        echo "[+] gtk set to Yaru-sage."
    ;;
    *)
        echo "[!] ${THEME} not found as a theme, try rainbowdash, fluttershy, or cat."
    ;;
esac

# default settings --------------------------------
echo "[i] modifying gsettings (dock, keybinds, nautilus, desktop prefs)..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.nautilus.preferences show-hidden-files false
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>c']"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Primary><Alt>t', '<Super>return']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.settings-daemon.plugins.media-keys search "['<Super>space']"
echo "[+] gsettings changes applied."
echo "[i] modifying dconf (terminal profiles)..."
dconf load /org/gnome/terminal/legacy/profiles:/ < "$(dirname "$0")/terminal_profiles.txt"
case "$THEME" in
    "rainbowdash")
        dconf write /org/gnome/terminal/legacy/profiles:/default "'ed52cdff-7201-4283-b859-7e4768a4f3fc'"
        echo "[+] terminal default theme set to rainbowdash."
    ;;
    "fluttershy")
        dconf write /org/gnome/terminal/legacy/profiles:/default "'446d91c3-37d6-45e7-bb22-b6d7bdfa63e9'"
        echo "[+] terminal default theme set to fluttershy."
    ;;
    "cat")
        dconf write /org/gnome/terminal/legacy/profiles:/default "'ed52cdff-7201-4283-b859-7e4768a4f3fc'"
        echo "[+] terminal default theme set to cat."
    ;;
    *)
        echo "[!] ${THEME} not found as a theme, try rainbowdash, fluttershy, or cat."
    ;;
esac
echo "[+] dconf changes applied."

# GNOME EXTENSIONS ==================================

# blur-my-shell --------------------------------
echo "[i] downloading blur-my-shell release v72..."
curl -L -o "$HOME/Downloads/blur-my-shell@aunetx.shell-extension.zip" "https://github.com/aunetx/blur-my-shell/releases/download/v72/blur-my-shell@aunetx.shell-extension.zip"
echo "[i] installing blur-my-shell."
gnome-extensions install "$HOME/Downloads/blur-my-shell@aunetx.shell-extension.zip"
echo "[+] blur-my-shell installed. re-log required for changes?"

echo "[i] modifying dconf blur-my-shell settings..."
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/blur true 
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/dynamic-opacity false 
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/sigma 25
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/static-blur false
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/sigma 25
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/static-blur false
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/sigma 25
dconf write /org/gnome/shell/extensions/blur-my-shell/pipelines "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}}"
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/whitelist "['org.gnome.Shell.Extensions', 'com.mattjakeman.ExtensionManager', 'firefox_firefox', 'gnome-terminal-server', 'discord', 'org.gnome.Nautilus', 'org.gnome.TextEditor']"
echo "[+] dconf blur-my-shell settings applied."

