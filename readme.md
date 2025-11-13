## needed programs
```
sudo pacman -S bob feh rustup zsh tmux zoxide kitty stow ly polybar rofi kmonad python-i3ipc docker lazydocker nvm pulsemixer dunst xclip flameshot
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
sudo systemctl stop lightdm
sudo systemctl disable lightdm
sudo systemctl enable ly
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

## devdocs
```
docker run --name devdocs -d -p 9292:9292 ghcr.io/freecodecamp/devdocs:latest
```

## clipboard
```
yay -Syu greenclip
```


## postgres
```
docker run --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres
```
