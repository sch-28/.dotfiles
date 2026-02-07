## needed programs
```
sudo pacman -S bob feh rustup zsh tmux zoxide kitty stow ly polybar rofi kmonad python-i3ipc docker lazydocker nvm pulsemixer dunst xclip flameshot jre-openjdk dbeaver maven clamav xorg-xsetroot nemo rofi-emoji harper 7zip
```

## node
```
nvm install 22.14
```

## stow
```
sudo rm -rf /etc/ly/config.ini
sudo sh stow-all.sh
```

## setup ly
```
sudo systemctl enable ly@tty1.service
sudo systemctl disable getty@tty1.service
sudo systemctl disable lightdm && sudo systemctl stop lightdm
```


## adjust sudo settings
```
sudo visudo
```

## install ohmyzsh & adjust shell
```
curl -L git.io/antigen > .antigen.zsh
chsh -s $(which zsh)
```

## wlan 
```
systemctl status NetworkManager
nmcli device wifi list
sudo nmcli device wifi connect "NAME" password "PASSWORD"
```
or
```
sudo nmtui
```

## clipboard
```
yay -Syu greenclip
```

## ssh key
```
ssh-keygen -t ed25519 -C "your_email@example.com"
```


## postgres
```
docker run --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres

sudo docker exec -it postgres psql -U postgres -c "CREATE DATABASE nova;" 
```

## gaming
```
sudo pacman -S --needed steam lutris wine-staging winetricks
# additional
sudo pacman -S --needed alsa-lib lib32-alsa-lib alsa-plugins lib32-alsa-plugins attr lib32-attr autoconf bison cabextract clang cmake cups desktop-file-utils dosbox ffmpeg flex fontconfig lib32-fontconfig fontforge freetype2 lib32-freetype2 gcc-libs lib32-gcc-libs gettext lib32-gettext giflib lib32-giflib git glib2-devel glslang gnutls lib32-gnutls gst-plugins-base-libs lib32-gst-plugins-base-libs gst-plugins-good lib32-gst-plugins-good gtk3 lib32-gtk3 gvfs libcups lib32-libcups libgphoto2 libgudev lib32-libgudev libpcap lib32-libpcap libpulse lib32-libpulse libsoup lib32-libsoup libva lib32-libva libvpx lib32-libvpx libxcomposite lib32-libxcomposite libxcursor lib32-libxcursor libxi lib32-libxi libxinerama lib32-libxinerama libxkbcommon lib32-libxkbcommon libxrandr lib32-libxrandr libxxf86vm lib32-libxxf86vm lld lzo mesa lib32-mesa mesa-libgl lib32-mesa-libgl meson mingw-w64-gcc nasm opencl-headers opencl-icd-loader lib32-opencl-icd-loader perl python python-pefile lib32-rust-libs samba sane sdl2 lib32-sdl2 speex lib32-speex unzip v4l-utils lib32-v4l-utils vkd3d lib32-vkd3d vulkan-headers vulkan-icd-loader lib32-vulkan-icd-loader wayland-protocols wget wine-gecko wine-mono winetricks giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse
```

## virus scan
```
clamscan -r /path/to/dir
```
