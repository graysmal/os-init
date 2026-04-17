# IMAGE_URL="https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/2ac70c0e-3d49-4027-8368-fc728831c239/diy5quc-f98bfe2d-6ea2-4cf2-83db-a41a92086867.png/v1/fill/w_1192,h_670,q_70,strp/_my_little_pony_windows_7_wallpaper_by_mlp123fan_diy5quc-pre.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTA4MCIsInBhdGgiOiIvZi8yYWM3MGMwZS0zZDQ5LTQwMjctODM2OC1mYzcyODgzMWMyMzkvZGl5NXF1Yy1mOThiZmUyZC02ZWEyLTRjZjItODNkYi1hNDFhOTIwODY4NjcucG5nIiwid2lkdGgiOiI8PTE5MjAifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.WNytG7eqmrf2WofwqtXVbjSXgNcJuk9cGFfQy4MI7UQ"
# IMAGE_PATH="$HOME/Pictures/backgrounds/wallpaper.jpg"

# echo "[i] sudo apt install curl"
# sudo apt install -y curl

# echo "[i] downloading wallpaper image from URL"
# curl --create-dirs -o "$IMAGE_PATH" "$IMAGE_URL"

# if [ -f "$IMAGE_PATH" ]; then
#    echo "[i] wallpaper exists at ~/Pictures/backgrounds/wallpaper.jpg"
#    echo "[+] setting org.gnome.desktop.background: picture uri, picture-options to image..."
#    gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE_PATH"
#    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMAGE_PATH"
#    gsettings set org.gnome.desktop.background picture-options "zoom"
# else
#    echo "[!] wallpaper does not exist at ~/Pictures/backgrounds/wallpaper.jpg"
# fi

# echo "[+] setting org.gnome.desktop gtk-theme to Yaru-blue..."
# gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue'
# echo "[+] setting org.gnome.shell.extensions.dask-to-dock position to BOTTOM..."
# gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
# echo "[+] setting org.gnome.shell.extensions.dask-to-dock extend-height (full-width) to false..."
# gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
# echo "[+] setting org.gnome.shell.extensions.dask-to-dock show-trash, show-mounts to false..."
# gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
# gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

# echo "[+] setting org.gnome.shell.extensions.ding show-home to false..."
# gsettings set org.gnome.shell.extensions.ding show-home false

# echo "[+] settings org.gnome.nautilus.preferences show-hidden-files to false..."
# gsettings set org.gnome.nautilus.preferences show-hidden-files false
# echo "[i] sudo apt install gnome-shell-extension-manager"
# sudo apt install -y gnome-shell-extension-manager



echo "[i] downloading blur-my-shell release v72..."
# curl -L -o "$HOME/Downloads/blur-my-shell@aunetx.shell-extension.zip" "https://github.com/aunetx/blur-my-shell/releases/download/v72/blur-my-shell@aunetx.shell-extension.zip"
echo "[+] blur-my-shell installed. relog required"
# gnome-extensions install "$HOME/Downloads/blur-my-shell@aunetx.shell-extension.zip"

echo "[+] adding applications to blur-my-shell"
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/blur true 
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/dynamic-opacity false 
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/sigma 25
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/whitelist "['org.gnome.Shell.Extensions', 'com.mattjakeman.ExtensionManager', 'firefox_firefox', 'gnome-terminal-server', 'discord']"

echo "[+] adding default pipeline to blur-my-shell (removing corners effect)"
dconf write /org/gnome/shell/extensions/blur-my-shell/pipelines "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}}"


dconf write /org/gnome/shell/extensions/blur-my-shell/panel/static-blur false
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/sigma 25
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/static-blur false
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/sigma 25
